require 'rubytus/api'
require 'rubytus/request'
require 'rubytus/error'
require 'rubytus/storage'
require 'rubytus/middlewares/tus_barrier'
require 'rubytus/middlewares/storage_barrier'

module Rubytus
  class Command < API
    include Constants
    include StorageHelper

    use Middlewares::TusBarrier
    use Middlewares::StorageBarrier

    def on_headers(env, headers)
      super(env, headers)

      request = Request.new(env)

      begin

        if env['api.action'] == :patch
          uid  = env['api.uid']
          info = storage.read_info(uid)

          validates_offset(request.offset, info.offset)
          validates_length(request.content_length, info.remaining_length)
        end

      rescue PermissionError => e
        error!(STATUS_INTERNAL_ERROR, e.message)
      end
    end

    def on_close(env)
      if env['api.action'] == :patch
        storage.patch_file(env['api.uid'], env['api.buffers'], env['api.offset'])
      end
    end

    def options_parser(opts, options)
      options = init_options.merge(options)
      default_parser(opts, options)
      opts.on('-f', '--data-dir DATA_DIR', "Directory to store uploads, LOCAL storage only (default: #{options[:data_dir]})") do |value|
        options[:data_dir] = value
      end
    end

    def init_options
      options = default_options
      options[:data_dir] = ENV[ENV_DATA_DIR] || DEFAULT_DATA_DIR
      options
    end

    def setup
      begin
        default_setup
        @options[:data_dir] = validates_data_dir(@options[:data_dir])
        @options[:storage]  = Storage.new(@options)
      rescue PermissionError, ConfigurationError => e
        puts '[ERROR] ' + e.message
        exit(1)
      end
    end

    private
    def storage
      @options[:storage]
    end
  end
end
