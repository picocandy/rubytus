require 'goliath'
require 'rubytus/uid'
require 'rubytus/error'
require 'rubytus/setup'
require 'rubytus/request'
require 'rubytus/storage'
require 'rubytus/rack/handler'

module Rubytus
  class API < Goliath::API
    include Rubytus::Setup

    use Rubytus::Rack::Handler

    def on_headers(env, headers)
      request = Rubytus::Request.new(env)

      env['api.headers'] = {
        'Content-Type'                  => 'text/plain; charset=utf-8',
        'Access-Control-Allow-Origin'   => '*',
        'Access-Control-Allow-Methods'  => 'HEAD,GET,PUT,POST,PATCH,DELETE',
        'Access-Control-Allow-Headers'  => 'Origin, X-Requested-With, Content-Type, Accept, Content-Disposition, Final-Length, Offset',
        'Access-Control-Expose-Headers' => 'Location, Range, Content-Disposition, Offset',
        'Date'                          => Time.now.httpdate
      }

      begin
        if request.collection? and request.post?
          uid = generate_uid

          env['api.action']       = :create
          env['api.uid']          = uid
          env['api.final_length'] = request.final_length
          env['api.resource_url'] = request.resource_url(uid)
        end

        if request.resource? and request.head?
          env['api.action'] = :head
          env['api.uid']    = request.resource_uid
        end

        if request.resource? and request.patch?
          if request.resumable_content_type?
            env['api.action'] = :patch
            env['api.uid']    = request.resource_uid
            env['api.offset'] = request.offset
          else
            raise HeaderError, "Content-Type must be 'application/offset+octet-stream'"
          end
        end

        if request.resource? and request.get?
          env['api.action'] = :get
          env['api.uid']    = request.resource_uid
        end
      rescue HeaderError => e
        raise Goliath::Validation::Error.new(400, e.message)
      end
    end

    def on_body(env, data)
      if env['api.action'] == :patch
        begin
          file = storage.patch_file(env['api.uid'], data)
          env['api.file'] = file
        rescue PermissionError => e
          raise Goliath::Validation::Error.new(500, e.message)
        end
      end
    end

    def on_close(env)
      file = env['api.file']

      if file
        storage.update_info(env['api.uid'], 'Offset' => file.size)
        file.close
      end
    end

    def response(env)
      status  = 200
      headers = env['api.headers']
      action  = env['api.action']
      body    = []

      begin
        case action
        when :create
          status = 201
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
