ENV['RACK_ENV'] ||= 'test'

require 'simplecov'
require 'minitest/autorun'
require 'rr'
require 'turn/autorun'
require 'rack'
require 'rack/test'
require 'pry'
require 'rubytus'

Turn.config do |c|
  c.format  = :outline
  c.natural = true
end

module Rubytus
  module Mock
    def app
      Rubytus::Server.configure do |config|
        config.data_dir  = data_dir
        config.base_path = '/uploads/'
      end

      base_app = lambda do |env|
        [200, {}, []]
      end

      Rack::Builder.new {
        use Rack::CommonLogger
        use Rubytus::Server
        run base_app
      }.to_app
    end

    def pdf
      File.expand_path('../files/protocol.pdf', __FILE__)
    end

    def uid
      Rubytus::Uid::uid
    end

    def data_dir
      "/tmp/rubytus-#{rand(1000)}"
    end

    def remove_data_dir
      FileUtils.rm_rf(Dir.glob("/tmp/rubytus-*"))
    end
  end
end
