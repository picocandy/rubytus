require 'rubytus/configuration'

module Rubytus
  class Server
    def initialize(app)
      @app = app
      @configuration = self.class.configuration
      @configuration.validates!
      @store = Store.new(@configuration)
    end

    def call(env)
      request = Request.new(env, @configuration)
      status, header, body = @app.call(env)
      @response = Rubytus::Response.new(body, status, header)

      begin
        if request.collection?
          if request.post?
            create_resource
          else
            @response['Allow'] = 'POST'
            @response.write "#{@request.request_method} used against file creation url. Only POST is allowed."
          end
        end

        if request.resource?
          if request.head?
            head_resource
          end

          if request.patch?
            patch_resource
            # request: Content-Length, Offset, (trim upload based on offset), Content-Type: application/offset+octet-stream
          end

          if request.get?
            get_resource
          end

          unless request.head? or request.patch? or request.get?
            @response['Allow'] = 'HEAD,PATCH'
          end
        end

        # TODO: optimize!
        if invalid_path?
          @response.status = 404
          @response.write('not found')
        end

      rescue HeaderError => e
        @response.status = 400
        @response.write(e.message)
      end

      @response.finish
    end

    def create_resource
      uid = Rubytus::Uid::uid

      @store.create_file(uid, @request.final_length)
      @response.status      = 201 # created
      @response['Location'] = resource_url(uid)
    end

    def head_resource
      @response.status    = 200
      @response['Offset'] = 10
    end

    def patch_resource
      @response.status    = 200
      @response['Offset'] = 10
    end

    def get_resource
      @response.write resource_path
    end

    def self.configure(&block)
      yield(configuration)
      configuration
    end

    def self.configuration
      @@configuration ||= Configuration.new
    end
  end
end
