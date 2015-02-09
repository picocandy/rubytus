require 'rubytus/constants'
require 'rubytus/common'
require 'rubytus/error'

module Rubytus
  module Helpers
    include Rubytus::Constants
    include Rubytus::Common

    def prepare_headers(env, headers)
      request = Rubytus::Request.new(env)

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

        env['api.action']       = :create
        env['api.uid']          = uid
        env['api.final_length'] = request.final_length
        env['api.resource_url'] = request.resource_url(uid)
        env['api.metadata']     = parse_metadata(headers['Metadata'])
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
  end
end
