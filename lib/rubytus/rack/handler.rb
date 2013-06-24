require 'rubytus/constants'

module Rubytus
  module Rack
    class Handler
      include Rubytus::Constants
      include Goliath::Rack::AsyncMiddleware

      def post_process(env, status, headers, body)
        request = Rubytus::Request.new(env)

        if request.collection?
          unless request.options? || request.post?
            status = STATUS_NOT_ALLOWED
            body   = "#{request.request_method} used against file creation url. Only POST is allowed."
            headers['Allow'] = 'POST'
          end
        end

        if request.resource?
          unless request.options? || request.head? || request.patch? || request.get?
            status  = STATUS_NOT_ALLOWED
            allowed = 'HEAD,PATCH'
            body    = "#{request.request_method} used against file creation url. Allowed: #{allowed}"
            headers['Allow'] = allowed
          end
        end

        if request.unknown?
          status = STATUS_NOT_FOUND
          body   = "Unknown url: #{request.path_info} - does not match file pattern"
        end

        [status, headers, body]
      end
    end
  end
end
