ENV['RACK_ENV'] ||= 'test'

require 'minitest/autorun'
require 'turn/autorun'

require 'rack'
require 'rack/test'

require 'rubytus'

Turn.config do |c|
  c.format  = :outline
  c.natural = true
end

module Rubytus
  module Mock
    def mock_app(&block)
      app = Class.new Rubytus::Server, &block
      app.new
    end
  end
end
