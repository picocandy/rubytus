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
        @response['Allow'] = 'POST'

        if @request.post?
          # create resource
        end
      end

      if resource_path?
        if @request.patch?
          # continue previously uploaded file
        end

        if @request.head?
          # fetch file metadata
        end

        if @request.get?
          @response.write resource_path
        end

        @response['Allow'] = 'HEAD,PATCH'
      end

      # TODO: optimize!
      unless collection_path? or resource_path?
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

    def resource_path
      path = @request.path
      path.slice!(@@configuration.base_path)
      path
    end
  end
end
