ENV['RACK_ENV'] ||= 'test'

require 'simplecov'
require 'minitest/autorun'
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
      Rack::Builder.new {
        use Rubytus::Server
        run lambda {|env| [200, {}, []]}
      }.to_app
    end
  end
end

