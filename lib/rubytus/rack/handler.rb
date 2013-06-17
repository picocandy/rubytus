module Rubytus
  module Rack
    class Handler
      include Goliath::Rack::AsyncMiddleware

      def post_process(env, status, headers, body)
        request = Rubytus::Request.new(env)

        if request.collection?
          unless request.options? or request.post?
            status = 405
            body   = "#{request.request_method} used against file creation url. Only POST is allowed."
            headers['Allow'] = 'POST'
          end
        end

        if request.resource?
          unless request.options? or request.head? or request.patch? or request.get?
            status  = 405
            allowed = 'HEAD,PATCH'
            body    = "#{request.request_method} used against file creation url. Allowed: #{allowed}"
            headers['Allow'] = allowed
          end
        end

        if request.unknown?
          status = 404
          body   = "unknown url: #{request.path_info} - does not match file pattern"
        end

        [status, headers, body]
      end
    end
  end
end
