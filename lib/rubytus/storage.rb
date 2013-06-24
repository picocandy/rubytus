require 'json'

module Rubytus
  class Storage
    def initialize(options)
      @options = options
    end

    def create_file(uid, final_length)
      fpath = file_path(uid)
      ipath = info_path(uid)
      info  = {
        'Offset'      => 0,
        'FinalLength' => final_length,
        'Meta'        => nil
      }

      begin
        File.open(fpath, 'w') {}
        File.open(ipath, 'w') do |f|
          f.write(JSON.dump(info))
        end
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def read_file(uid)
      fpath = file_path(uid)

      begin
        f = File.open(fpath, 'rb')
        f.read
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      ensure
        f.close unless f.nil?
      end
    end

    def open_file(uid, offset = nil)
      fpath = file_path(uid)

      begin
        f = File.open(fpath, 'r+b')
        f.sync = true
        f.seek(offset) unless offset.nil?
        f
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def patch_file(f, data)
      begin
        f.write(data)
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def read_info(uid)
      ipath = info_path(uid)

      begin
        JSON.parse(File.open(ipath, 'r') { |f| f.read })
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def update_info(uid, info)
      ipath = info_path(uid)
      info = read_info(uid).merge(info)

      begin
        File.open(ipath, 'w') do |f|
          f.write(JSON.dump(info))
        end
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def file_path(uid)
      File.join(@options[:data_dir], "#{uid}.bin")
    end

    def info_path(uid)
      File.join(@options[:data_dir], "#{uid}.info")
    end
  end
end
