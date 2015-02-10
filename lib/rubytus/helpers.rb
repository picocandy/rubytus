require 'rubytus/constants'
require 'rubytus/common'
require 'rubytus/error'

module Rubytus
  module Helpers
    include Rubytus::Constants
    include Rubytus::Common

    def prepare_headers(env, headers)
      request = Rubytus::Request.new(env)

      env['api.headers'].merge!(handle_cors(request, headers))

      if request.collection? || request.resource?
        validates_supported_version(headers["Tus-Resumable"])
      end

      # OPTIONS
      if request.collection? && request.options?
        env['api.headers'].merge!({
          'TUS-Extension' => SUPPORTED_EXTENSIONS.join(','),
          'TUS-Max-Size'  => env['api.options'][:max_size].to_s
        })
      end

      # CREATE
      if request.collection? && request.post?
        uid = generate_uid

        env['api.action']        = :create
        env['api.uid']           = uid
        env['api.entity_length'] = request.entity_length
        env['api.resource_url']  = request.resource_url(uid)
        env['api.metadata']      = parse_metadata(headers['Metadata'])
      end

      if request.resource?
        # UID for this resource
        env['api.uid'] = request.resource_uid

        # HEAD
        if request.head?
          env['api.action'] = :head
        end

        # PATCH
        if request.patch?
          validates_content_type(request)
          validate_entity_length(headers['Entity-Length'].to_i)

          env['api.action']  = :patch
          env['api.buffers'] = ''
          env['api.offset']  = request.offset
        end

        # GET
        if request.get?
          env['api.action'] = :get
        end
      end
    end

    def validates_offset(req_offset, info_offset)
      if req_offset > info_offset
        error!(STATUS_FORBIDDEN, "Offset: #{req_offset} exceeds current offset: #{info_offset}")
      end
    end

    def validates_length(req_length, remaining)
      if req_length > remaining
        error!(STATUS_FORBIDDEN, "Content-Length: #{req_length} exceeded remaining length: #{remaining}")
      end
    end

    def validates_base_path(base_path)
      unless base_path =~ BASE_PATH_REGEX
        raise ConfigurationError, "Invalid `base_path` configuration, it should be using format /uploads/, /user-data/, etc"
      end

      base_path
    end

    def validates_max_size(max_size)
      if max_size.is_a? String
        max_size = max_size.to_i
      end

      if max_size <= 0
        raise ConfigurationError, "Invalid `max_size`, it should be > 0 bytes"
      end

      max_size
    end

    def validates_content_type(request)
      unless request.resumable_content_type?
        error!(STATUS_BAD_REQUEST, "Content-Type must be '#{RESUMABLE_CONTENT_TYPE}'")
      end
    end

    def validates_supported_version(version)
      unless SUPPORTED_VERSIONS.include?(version)
        error!(STATUS_PRECONDITION_FAILED, "Unsupported version: #{version}. Please use: #{SUPPORTED_VERSIONS.join(', ')}.")
      end
    end

    def parse_metadata(metadata)
      return if metadata.nil?
      arr = metadata.split(' ')

      if (arr.length % 2 == 1)
        error!(STATUS_BAD_REQUEST, "Metadata must be a key-value pair")
      end

      Hash[*arr].inject({}) do |h, (k, v)|
        h[k] = Base64.decode64(v)
        h
      end
    end

    def handle_cors(request, headers)
      origin = headers['Origin']

      return {} if origin.nil? || origin == ""

      cors_headers = {}
      cors_headers['Access-Control-Allow-Origin'] = origin

      if request.options?
        cors_headers['Access-Control-Allow-Methods']  = "POST, HEAD, PATCH, OPTIONS"
        cors_headers['Access-Control-Allow-Headers']  = "Origin, X-Requested-With, Content-Type, Entity-Length, Offset, TUS-Resumable"
        cors_headers['Access-Control-Max-Age']        = "86400"
      else
        cors_headers['Access-Control-Expose-Headers'] = "Offset, Location, Entity-Length, TUS-Version, TUS-Resumable, TUS-Max-Size, TUS-Extension"
      end

      cors_headers
    end

    def validate_entity_length(length)
      if length == 0
        error!(STATUS_BAD_REQUEST, "Invalid Entity-Length: #{length}. It should non-negative integer or string 'streaming'")
      end
    end
  end
end
