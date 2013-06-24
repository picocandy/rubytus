require 'goliath'
require 'rubytus/uid'
require 'rubytus/error'
require 'rubytus/setup'
require 'rubytus/request'
require 'rubytus/storage'
require 'rubytus/constants'
require 'rubytus/rack/handler'

module Rubytus
  class API < Goliath::API
    include Rubytus::Constants
    include Rubytus::Setup

    use Rubytus::Rack::Handler

    def on_headers(env, headers)
      request = Rubytus::Request.new(env)

      env['api.options'] = @options
      env['api.headers'] = INITIAL_HEADERS.merge({
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

          if request.offset > info['Offset']
            raise UploadError, "Offset: #{request.offset} exceeds current offset: #{info['Offset']}"
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
        storage.update_info(env['api.uid'], 'Offset' => size)
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
          data   = {
            :final_length => env['api.final_length']
          }

          storage.create_file(env['api.uid'], data)
          headers['Location'] = env['api.resource_url']

        when :head
          info = storage.read_info(env['api.uid'])
          headers['Offset'] = info['Offset'].to_s

        when :get
          body = storage.read_file(env['api.uid'])
        end
      rescue PermissionError => e
        raise Goliath::Validation::Error.new(500, e.message)
      end

      [status, headers, body]
    end

    private
    def generate_uid
      Rubytus::Uid.uid
    end
  end
end
