require 'goliath'
require 'goliath/constants'
require 'rubytus/constants'
require 'rubytus/request'
require 'rubytus/helpers'
require 'rubytus/error'
require 'stringio'

module Rubytus
  class API < Goliath::API
    include Goliath::Constants
    include Rubytus::Constants
    include Rubytus::Helpers

    def on_headers(env, headers)
      env['api.options'] = @options
      env['api.headers'] = {
        'TUS-Resumable' => '1.0.0',
        'Date' => Time.now.httpdate
      }

      prepare_headers(env, headers)
    end

    def on_body(env, data)
      if env['api.action'] == :patch
        env['api.buffers'] << data
      else
        body = StringIO.new(data)
        env[RACK_INPUT] = body
      end
    end

    def response(env)
      status  = STATUS_OK
      headers = env['api.headers']
      body    = []

      [status, headers, body]
    end

    def default_setup
      @options[:max_size]  = validates_max_size(@options[:max_size])
      @options[:base_path] = validates_base_path(@options[:base_path])
    end

    def default_options
      {
        :base_path => ENV[ENV_BASE_PATH] || DEFAULT_BASE_PATH,
        :max_size  => ENV[ENV_MAX_SIZE]  || DEFAULT_MAX_SIZE
      }
    end

    def default_parser(opts, options)
      opts.separator ""
      opts.separator "TUSD options:"

      args = [
        {
          :name  => :base_path,
          :short => '-b',
          :long  => '--base-path BASE_PATH',
          :desc  => "Url path used for handling uploads (default: #{options[:base_path]})"
        },
        {
          :name  => :max_size,
          :short => '-m',
          :long  => '--max-size MAX_SIZE',
          :desc  => "Maximum bytes may be stored inside storage (default: #{options[:max_size]})"
        }
      ]

      args.each do |arg|
        opts.on(arg[:short], arg[:long], arg[:desc]) do |value|
          options[arg[:name]] = value
        end
      end

      # save into global options
      @options = options
    end
  end
end
