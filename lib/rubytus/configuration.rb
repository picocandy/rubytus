module Rubytus
  class Configuration
    BASE_PATH_REGEX = /^(\/[a-zA-Z0-9\-_]+\/)$/

    attr_accessor :data_dir
    attr_accessor :max_size
    attr_accessor :base_path

    def initialize(options = {})
      @data_dir  = options[:data_dir]  || ENV['TUSD_DATA_DIR']  || 'tus_data'
      @base_path = options[:base_path] || ENV['TUSD_BASE_PATH'] || '/files/'
      @max_size  = options[:max_size]  || ENV['TUSD_MAX_SIZE']  || 1024 * 1024 * 1024
    end

    def validates!
      validate_base_path
      validate_data_dir
      validate_max_size
    end

    def validate_data_dir
      data_dir = File.expand_path(@data_dir)

      begin
        unless File.directory?(data_dir)
          Dir.mkdir(data_dir)
        end
      rescue SystemCallError => _
        raise PermissionError, "Couldn't create `data_dir` in #{data_dir}"
      end

      File.chmod(0777, data_dir)
      @data_dir = data_dir
    end

    def validate_max_size
      if @max_size.is_a? String
        @max_size = @max_size.to_i
      end

      if @max_size <= 0
        raise ConfigurationError, "Invalid `max_size`, it should be > 0 bytes"
      end
    end

    def validate_base_path
      unless @base_path =~ BASE_PATH_REGEX
        raise ConfigurationError, "Invalid `base_path` configuration, it should be using format /uploads/, /user-data/, etc"
      end
    end
  end
end
