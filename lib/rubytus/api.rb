require 'goliath'
require 'rubytus/error'
require 'rubytus/helpers'
require 'rubytus/request'
require 'rubytus/storage'
require 'rubytus/constants'
require 'rubytus/rack/handler'

module Rubytus
  class API < Goliath::API
    include Rubytus::Constants
    include Rubytus::Helpers

    use Rubytus::Rack::Handler

    def on_headers(env, headers)
      request = Rubytus::Request.new(env)

      env['api.options'] = @options
      env['api.headers'] = COMMON_HEADERS.merge({
        'Date' => Time.now.httpdate
      })

      begin
        if request.collection? && request.post?
          uid = generate_uid

          env['api.action']       = :create
          env['api.uid']          = uid
          env['api.final_length'] = request.final_length
          env['api.resource_url'] = request.resource_url(uid)
        end

        if request.resource? && request.head?
          env['api.action'] = :head
          env['api.uid']    = request.resource_uid
        end

        if request.resource? && request.patch?
          unless request.resumable_content_type?
            raise HeaderError, "Content-Type must be '#{RESUMABLE_CONTENT_TYPE}'"
          end

          uid  = request.resource_uid
          info = storage.read_info(uid)

          if request.offset > info.offset
            raise UploadError, "Offset: #{request.offset} exceeds current offset: #{info.offset}"
          end

          if request.content_length > info.remaining_length
            raise UploadError, "Content-Length: #{request.content_length} exceeded desired length: #{info.remaining_length}"
          end

          if request.total_length > info.final_length
            raise UploadError, "Content-Length + Offset (#{request.total_length}) exceeded final length: #{info.final_length}"
          end

          env['api.action'] = :patch
          env['api.uid']    = uid
          env['api.file']   = storage.open_file(uid, request.offset)
        end

        if request.resource? && request.get?
          env['api.action'] = :get
          env['api.uid']    = request.resource_uid
        end

      rescue HeaderError => e
        raise Goliath::Validation::Error.new(STATUS_BAD_REQUEST, e.message)

      rescue UploadError => e
        raise Goliath::Validation::Error.new(STATUS_FORBIDDEN, e.message)
      end
    end

    def on_body(env, data)
      if env['api.action'] == :patch
        storage.patch_file(env['api.file'], data)
      end
    end

    def on_close(env)
      file = env['api.file']

      if file
        size = file.size
        file.close unless file.closed?
        storage.update_info(env['api.uid'], size)
      end
    end

    def response(env)
      status  = STATUS_OK
      headers = env['api.headers']
      action  = env['api.action']
      body    = []

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
