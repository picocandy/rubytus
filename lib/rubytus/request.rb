require 'rack'

module Rubytus
  class Request < Rack::Request
    RESOURCE_NAME_REGEX = /^([a-z0-9]{32})$/

    def initialize(env, configuration)
      @env = env
      @configuration = configuration
      super(@env)
    end

    def unknown?
      !collection? && !resource?
    end

    def collection?
      path.chomp('/') == @configuration.base_path.chomp('/')
    end

    def resource?
      !!(resource_name =~ RESOURCE_NAME_REGEX)
    end

    def resource_name
      rpath = path
      rpath.slice!(@configuration.base_path)
      rpath
    end

    def resource_url(uid)
      "#{scheme}://#{host_with_port}#{@configuration.base_path}#{uid}"
    end

    def final_length
      fetch_positive_header('HTTP_FINAL_LENGTH')
    end

    def offset
      fetch_positive_header('HTTP_OFFSET')
    end

    protected
    def fetch_positive_header(header_name)
      value       = @env.fetch(header_name, '0').to_i
      orig_header = http_orig_header(header_name)

      if value.zero?
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
