require 'pathname'
require 'rubytus/constants'

module Rubytus
  module Setup
    include Rubytus::Constants

    attr_reader :storage

    def options_parser(opts, options)
      options = init_options.merge(options)

      opts.separator ""
      opts.separator "TUSD options:"

      opts.on('-f', '--data-dir DATA_DIR', "Directory to store uploaded and partial files (default: #{options[:data_dir]})") do |value|
        options[:data_dir] = value
      end

      opts.on('-b', '--base-path BASE_PATH', "Url path used for handling uploads (default: #{options[:base_path]})") do |value|
        options[:base_path] = value
      end

      opts.on('-m', '--max-size MAX_SIZE', "How many bytes may be stored inside DATA_DIR (default: #{options[:max_size]})") do |value|
        options[:max_size] = value
      end

      @options = options
      opts
    end

    def init_options
      {
        :data_dir  => ENV[ENV_DATA_DIR]  || DEFAULT_DATA_DIR,
        :base_path => ENV[ENV_BASE_PATH] || DEFAULT_BASE_PATH,
        :max_size  => ENV[ENV_MAX_SIZE]  || DEFAULT_MAX_SIZE
      }
    end

    def init_storage(opts)
      Storage.new(opts)
    end

    def setup
      begin
        @options[:data_dir]  = validate_data_dir(@options[:data_dir])
        @options[:max_size]  = validate_max_size(@options[:max_size])
        @options[:base_path] = validate_base_path(@options[:base_path])
        @storage = init_storage(@options)
      rescue PermissionError, ConfigurationError => e
        puts '[ERROR] ' + e.message
        exit(1)
      end
    end

    def validate_data_dir(data_dir)
      if Pathname.new(data_dir).relative?
        data_dir = File.join(ENV['PWD'], data_dir)
      end

      begin
        unless File.directory?(data_dir)
          Dir.mkdir(data_dir)
        end
      rescue SystemCallError => _
        raise PermissionError, "Couldn't create `data_dir` in #{data_dir}"
      end

      unless File.world_writable?(data_dir)
        File.chmod(0777, data_dir)
      end

      data_dir
    end

    def validate_base_path(base_path)
      unless base_path =~ BASE_PATH_REGEX
        raise ConfigurationError, "Invalid `base_path` configuration, it should be using format /uploads/, /user-data/, etc"
      end

      base_path
    end

    def validate_max_size(max_size)
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
