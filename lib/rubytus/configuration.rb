module Rubytus
  class Configuration
    attr_reader :data_dir
    attr_reader :max_size
    attr_reader :base_path

    def initialize(options = {})
      @data_dir  = options[:data_dir]  || ENV['TUSD_DATA_DIR']  || 'tus_data'
      @base_path = options[:base_path] || ENV['TUSD_BASE_PATH'] || '/files/'
      @max_size  = options[:max_size]  || ENV['TUSD_MAX_SIZE']  || 1024 * 1024 * 1024
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
  end
end
