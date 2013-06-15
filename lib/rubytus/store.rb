require 'json'

module Rubytus
  class Store
    def initialize(configuration)
      @configuration = configuration
    end

    def create_file(uid, options = {})
      data = {
        'Offset'      => 0,
        'FinalLength' => options[:final_length],
        'Meta'        => nil
      }

      write_file(uid)
      write_info(uid, data)
    end

    def file_path(uid)
      File.join(@configuration.data_dir, "#{uid}.bin")
    end

    def info_path(uid)
      File.join(@configuration.data_dir, "#{uid}.info")
    end

    def write_file(uid)
      begin
        File.open(file_path(uid), 'w') do |f|
          f.write('')
        end
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def write_info(uid, data)
      begin
        File.open(info_path(uid), 'w') do |f|
          f.write(data.to_json)
        end
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def read_info(uid)
      begin
        JSON.parse(IO.read(info_path(uid)))
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end
  end
end
