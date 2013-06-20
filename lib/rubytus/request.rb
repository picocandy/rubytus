module Rubytus
  class Request
    RESOURCE_UID_REGEX = /^([a-z0-9]{32})$/
    RESUMABLE_CONTENT_TYPE = 'application/offset+octet-stream'

    def initialize(env)
      @env = env
    end

    def get?;     request_method == 'GET'; end
    def post?;    request_method == 'POST'; end
    def head?;    request_method == 'HEAD'; end
    def patch?;   request_method == 'PATCH'; end
    def options?; request_method == 'OPTIONS'; end

    def request_method
      @env['REQUEST_METHOD']
    end

    def resumable_content_type?
      @env['CONTENT_TYPE'] == RESUMABLE_CONTENT_TYPE
    end

    def unknown?
      !collection? && !resource?
    end

    def collection?
      path_info.chomp('/') == @env.options[:base_path].chomp('/')
    end

    def resource?
      !!(resource_uid =~ RESOURCE_UID_REGEX)
    end

    def resource_uid
      rpath = path_info.dup
      rpath.slice!(@env.options[:base_path])
      rpath
    end

    def resource_url(uid)
      "http://#{host_with_port}#{@env.options[:base_path]}#{uid}"
    end

    def final_length
      fetch_positive_header('HTTP_FINAL_LENGTH')
    end

    def offset
      fetch_positive_header('HTTP_OFFSET')
    end

    def path_info
      @env['PATH_INFO']
    end

    def host_with_port
      @env['HTTP_HOST'] || "#{@env['SERVER_NAME'] || @env['SERVER_ADDR']}:#{@env['SERVER_PORT']}"
    end

    protected
    def fetch_positive_header(header_name)
      header_val  = @env.fetch(header_name, '')
      value       = header_val.to_i
      orig_header = http_orig_header(header_name)

      if header_val.empty?
        raise HeaderError, "#{orig_header} header must not be empty"
      end

      if value < 0
        raise HeaderError, "#{orig_header}, header must be > 0"
      end

      value
    end

    def http_orig_header(header_name)
      header_name.gsub('HTTP_', '').split('_').map(&:capitalize).join('-')
    end
  end
end

