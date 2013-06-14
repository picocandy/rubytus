require 'rubytus/configuration'

module Rubytus
  class Server
    RESOURCE_NAME_REGEX = /^([a-z0-9]{32})$/

    attr_reader :configuration

    def initialize(app)
      @app           = app
      @configuration = self.class.configuration
      @store         = Store.new(@configuration)

      # OPTIMIZE: move to proper place
      @configuration.validates!
    end

    def call(env)
      @request = Rack::Request.new(env)
      status, header, body = @app.call(env)
      @response = Rubytus::Response.new(body, status, header)

      begin
        if collection_path?
          if @request.post?
            create_resource
          else
            @response['Allow'] = 'POST'
            @response.write "#{@request.request_method} used against file creation url. Only POST is allowed."
          end
        end

        if resource_path?
          if @request.head?
            head_resource
          end

          if @request.patch?
            patch_resource
            # request: Content-Length, Offset, (trim upload based on offset), Content-Type: application/offset+octet-stream
          end

          if @request.get?
            get_resource
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

      rescue HeaderError => e
        @response.status = 400
        @response.write(e.message)
      end

      @response.finish
    end

    def create_resource
      uid          = Rubytus::Uid::uid
      final_length = get_positive_header('Final-Length')

      @store.create_file(uid, final_length)
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

    def resource_url(uid)
      "#{@request.scheme}://#{@request.host_with_port}#{configuration.base_path}#{uid}"
    end

    def invalid_path?
      !collection_path? && !resource_path?
    end

    def collection_path?
      @request.path.chomp('/') == configuration.base_path.chomp('/')
    end

    def resource_path?
      !!(resource_path =~ RESOURCE_NAME_REGEX)
    end

    def resource_path
      path = @request.path
      path.slice!(configuration.base_path)
      path
    end

    def get_positive_header(key)
      # Final-Length -> HTTP_FINAL_LENGTH
      header_name = 'HTTP_' + key.gsub('-', '_').upcase
      value       = @request.env.fetch(header_name, '0').to_i

      if value.zero?
        raise HeaderError, "#{key} header must not be empty"
      end

      if value < 0
        raise HeaderError, "#{key}, header must be > 0"
      end

      value
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
