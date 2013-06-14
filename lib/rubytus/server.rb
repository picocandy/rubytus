require 'rubytus/configuration'

module Rubytus
  class Server
    def initialize(app)
      @app     = app
      @handler = Rubytus::Handler.new(self.class.configuration)
    end

    def call(env)
      @request = Rack::Request.new(env)
      status, header, body = @app.call(env)
      @response = Rubytus::Response.new(body, status, header)

      if collection_path?
        if @request.post?
          # create resource
        else
          @response['Allow'] = 'POST'
        end
      end

      if resource_path?
        if @request.head?
          # fetch file metadata
          # response: 200, Offset
        end

        if @request.patch?
          # continue previously uploaded file
          # request: Content-Length, Offset, (trim upload based on offset), Content-Type: application/offset+octet-stream
          # response: 200
        end

        if @request.get?
          @response.write resource_path
        end

        unless @request.head? or @request.patch? or @request.get?
          @response['Allow'] = 'HEAD,PATCH'
        end
      end

      # TODO: optimize!
      if invalid_path?
        @response.status = 404
        @response.write('not found')
      end

      @response.finish
    end

    class << self
      def configure(&block)
        yield(configuration)
        configuration
      end

      def configuration
        @@configuration ||= Configuration.new
      end
    end

    private
    def collection_path?
      @request.path == @@configuration.base_path.chomp('/')
    end

    def resource_path?
      resource_path =~ /^([a-z0-9]{32})$/
    end

    def invalid_path?
      !collection_path? || !resource_path?
    end

    def resource_path
      path = @request.path
      path.slice!(@@configuration.base_path)
      path
    end
  end
end
