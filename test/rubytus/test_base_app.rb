require 'test_helper'
require 'rubytus/base_app'

class TestBaseApp < MiniTest::Unit::TestCase
  def setup
    @base_app = Rubytus::BaseApp.call({})
  end

  def test_call
    assert_equal 200, @base_app[0] # status
    assert_equal Hash.new, @base_app[1] # header
    assert_equal [], @base_app[2] # body
  end
end
