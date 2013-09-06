require 'json'
require 'rubytus/info'

module Rubytus
  class Storage
    def initialize(options)
      @options = options
    end

    def create_file(uid, final_length)
      fpath = file_path(uid)
      ipath = info_path(uid)
      info  = Rubytus::Info.new
      info.final_length = final_length

      begin
        File.open(fpath, 'w') {}
        File.open(ipath, 'w') do |f|
          f.write(info.to_json)
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

    def patch_file(uid, data, offset = nil)
      fpath = file_path(uid)
      begin
        f = File.open(fpath, 'r+b')
        f.sync = true
        f.seek(offset) unless offset.nil?
        f.write(data)
        size = f.size
        f.close
        update_info(uid, size)
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    def read_info(uid)
      ipath = info_path(uid)

      begin
        data = File.open(ipath, 'r') { |f| f.read }
        JSON.parse(data, :object_class => Rubytus::Info)
      rescue SystemCallError => e
        raise(PermissionError, e.message) if e.class.name.start_with?('Errno::')
      end
    end

    private
    def update_info(uid, offset)
      ipath = info_path(uid)
      info = read_info(uid)
      info.offset = offset

      begin
        File.open(ipath, 'w') do |f|
          f.write(info.to_json)
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
