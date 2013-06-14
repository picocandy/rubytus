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
            create_resource(request.final_length)
          else
            @response.method_not_allowed!
            @response['Allow'] = 'POST'
            @response.write "#{request.request_method} used against file creation url. Only POST is allowed."
          end
        end

        if request.resource?
          head_resource  if request.head?
          patch_resource if request.patch?
          get_resource   if request.get?

          unless request.head? or request.patch? or request.get?
            allowed = 'HEAD,PATCH'
            @response.method_not_allowed!
            @response['Allow'] = allowed
            @response.write "#{request.request_method} used against file creation url. Allowed: #{allowed}"
          end
        end

        if request.unknown?
          @response.not_found!
          @response.write("unknown url: #{request.path} - does not match file pattern")
        end

      rescue PermissionError => e
        @response.server_error!

      rescue HeaderError => e
        @response.bad_request!
        @response.write(e.message)
      end

      @response.finish
    end

    def create_resource(final_length)
      uid = Rubytus::Uid::uid

      @store.create_file(uid, final_length)
      @response.created!
      @response['Location'] = resource_url(uid)
    end

    def head_resource
      @response['Offset'] = 0
    end

    def patch_resource
      @response['Offset'] = 0
    end

    def get_resource(resource)
      @response.write(resource)
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
