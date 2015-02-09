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

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

Goliath.env = :test

module Rubytus
  module Assertions
    def assert_has_protocol(headers)
      assert_equal '1.0.0', headers["TUS_RESUMABLE"]
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
