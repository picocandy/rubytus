require 'rubytus/constants'
require 'rubytus/common'
require 'rubytus/error'

module Rubytus
  module Helpers
    include Rubytus::Constants
    include Rubytus::Common

    def prepare_headers(env, headers)
      request = Rubytus::Request.new(env)

      # CREATE
      if request.collection? && request.post?
        uid = generate_uid

        env['api.action']       = :create
        env['api.uid']          = uid
        env['api.final_length'] = request.final_length
        env['api.resource_url'] = request.resource_url(uid)
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
          unless request.resumable_content_type?
            error!(STATUS_BAD_REQUEST, "Content-Type must be '#{RESUMABLE_CONTENT_TYPE}'")
          end

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
  end
end
