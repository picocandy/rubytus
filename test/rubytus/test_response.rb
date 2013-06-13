require 'test_helper'

class TestResponse < MiniTest::Unit::TestCase
  def setup
    @response = Rubytus::Response.new
  end

  def test_initialize
    assert_equal 'text/plain; charset=utf-8', @response.headers['Content-Type']
  end
end
