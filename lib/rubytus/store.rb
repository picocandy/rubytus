module Rubytus
  class Store
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def create_file(uid, final_length)
      write_file(uid)
      write_info(uid)
    end

    def file_path(uid)
      File.join(configuration.data_dir, "#{uid}.bin")
    end

    def info_path(uid)
      File.join(configuration.data_dir, "#{uid}.info")
    end

    def write_file(uid)
      begin
        File.open(file_path(uid), 'w') do |f|
          f.write('')
        end
      rescue Errno::EEXIST => e
        raise PermissionError, e.message
      end
    end

    def write_info(uid)
      begin
        File.open(info_path(uid), 'w') do |f|
          f.write('')
        end
      rescue Errno::EEXIST => e
        raise PermissionError, e.message
      end
    end
  end
end
