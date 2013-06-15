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
        config.data_dir  = "/tmp/rubytusd-#{rand(1000)}"
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
  end
end
