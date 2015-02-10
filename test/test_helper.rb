require 'simplecov'
require 'coveralls'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rr'
require 'goliath/test_helper'
require 'rubytus/error'
require 'rubytus/helpers'
require 'rubytus/common'
require 'rubytus/storage'
require 'pry'
require 'base64'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

Goliath.env = :test

def json_decode(str)
  MultiJson.load(str, :symbolize_keys => true)
end

module Rubytus
  module Assertions
    def assert_tus_protocol(headers, version = '1.0.0')
      assert_equal version, headers["TUS_RESUMABLE"]
    end

    def assert_tus_extensions(headers, extensions)
      assert_equal extensions, headers['TUS_EXTENSION'].split(',')
    end

    def assert_tus_max_size(headers, max_size = DEFAULT_MAX_SIZE)
      assert_equal max_size.to_s, headers['TUS_MAX_SIZE']
    end

    def assert_tus_cors_option(headers, origin = '*')
      assert_equal origin, headers['Access-Control-Allow-Origin']
      assert_equal "POST, HEAD, PATCH, OPTIONS", headers['Access-Control-Allow-Methods']
      assert_equal "Origin, X-Requested-With, Content-Type, Entity-Length, Offset, TUS-Resumable", headers['Access-Control-Allow-Headers']
      assert_equal "86400", headers['Access-Control-Max-Age']
    end

    def assert_tus_cors_expose(headers, origin = '*')
      assert_equal "Offset, Location, Entity-Length, TUS-Version, TUS-Resumable, TUS-Max-Size, TUS-Extension", headers['Access-Control-Expose-Headers']
    end

    def assert_error_message(message, response)
      json = json_decode(response)
      assert_equal message, json[:error]
    end
  end

  module Mock
    include Rubytus::Helpers
    include Rubytus::Common
    include Rubytus::Constants
    include Rubytus::Assertions

    def data_dir
      "/tmp/rubytus-#{rand(1000)}"
    end

    def remove_data_dir
      FileUtils.rm_rf(Dir.glob("/tmp/rubytus-*"))
    end

    def uid
      generate_uid
    end

    def default_options
      {
        :data_dir  => data_dir,
        :max_size  => 1024 * 1024,
        :base_path => '/uploads/'
      }
    end

    def read_only_options
      default_options.merge({
        :data_dir => '/opt/rubytus'
      })
    end

    def encode64(str)
      Base64.encode64(str).gsub("\n", '')
    end

    class Config
      include Rubytus::Helpers
      include Rubytus::Common
      include Rubytus::Constants
      include Rubytus::StorageHelper
    end
  end
end

module Goliath
  module TestHelper
    def server(api, port, options = {}, &blk)
      op = OptionParser.new

      s = Goliath::Server.new
      s.logger = setup_logger(options)
      s.api = api.new
      s.app = Goliath::Rack::Builder.build(api, s.api)
      s.api.options_parser(op, options)
      s.options = options
      s.port = port
      s.plugins = api.plugins
      s.api.setup if s.api.respond_to?(:setup)
      @test_server_port = s.port if blk
      s.start(&blk)
      s
    end
  end
end
