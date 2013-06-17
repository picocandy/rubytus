require 'json'

module Rubytus
  class Store
    def initialize(configuration)
      @configuration = configuration
    end

    def create_file(uid, options = {})
      info = {
        'Offset'      => 0,
        'FinalLength' => options[:final_length],
        'Meta'        => nil
      }

      write_file(uid, nil, info['Offset'])
      write_info(uid, info.to_json)
    end

    def patch_file(uid, input, options)
      write_file(uid, input.read, options[:offset])
      new_offset = options[:offset] + options[:content_length]
      update_info(uid, 'Offset' => new_offset, 'MimeType' => options[:mime_type])
    end

    def read_file(uid)
      IO.binread(file_path(uid))
    end

    def file_path(uid)
      File.join(@configuration.data_dir, "#{uid}.bin")
    end

    def info_path(uid)
      File.join(@configuration.data_dir, "#{uid}.info")
    end

    def write_file(uid, data, offset)
      begin
        IO.write(file_path(uid), data, offset, :mode => 'ab')
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def write_info(uid, info)
      begin
        IO.write(info_path(uid), info, 0, :mode => 'w')
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

    def update_info(uid, data)
      info = read_info(uid).merge(data)
      write_info(uid, info.to_json)
    end
  end
end
