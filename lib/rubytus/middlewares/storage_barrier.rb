require 'rubytus/error'

module Rubytus
  module Middlewares
    class StorageBarrier
      include Rubytus::Constants
      include Goliath::Rack::AsyncMiddleware

      def post_process(env, status, headers, body)
        status  = STATUS_OK
        action  = env['api.action']
        storage = env['api.options'][:storage]

        begin
          case action
          when :create
            status = STATUS_CREATED
            headers['Location'] = env['api.resource_url']
            storage.create_file(env['api.uid'], env['api.final_length'])

          when :head
            info = storage.read_info(env['api.uid'])
            headers['Offset'] = info.offset.to_s

          when :get
            body = storage.read_file(env['api.uid'])
          end
        rescue PermissionError => e
          raise Goliath::Validation::Error.new(500, e.message)
        end

        [status, headers, body]
      end
    end
  end
end
