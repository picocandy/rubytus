module Rubytus
  module Setup
    BASE_PATH_REGEX = /^(\/[a-zA-Z0-9\-_]+\/)$/

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

      @opts = options
    end

    def init_options
      {
        :data_dir  => ENV['TUSD_DATA_DIR']  || 'tus_data',
        :base_path => ENV['TUSD_BASE_PATH'] || '/files/',
        :max_size  => ENV['TUSD_MAX_SIZE']  || 1024 * 1024 * 1024
      }
    end

    def init_storage(opts)
      Storage.new(opts)
    end

    def setup
      begin
        @opts[:data_dir]  = validate_data_dir(@opts[:data_dir])
        @opts[:max_size]  = validate_max_size(@opts[:max_size])
        @opts[:base_path] = validate_base_path(@opts[:base_path])
        @storage = init_storage(@opts)
      rescue PermissionError, ConfigurationError => e
        puts '[ERROR] ' + e.message
        exit(1)
      end
    end

    def validate_data_dir(data_dir)
      expand_dir = File.expand_path(data_dir)

      begin
        unless File.directory?(expand_dir)
          Dir.mkdir(expand_dir)
        end
      rescue SystemCallError => _
        raise PermissionError, "Couldn't create `data_dir` in #{expand_dir}"
      end

      unless File.world_writable?(expand_dir)
        File.chmod(0777, expand_dir)
      end

      expand_dir
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
