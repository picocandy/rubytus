require 'test_helper'

class TestServer < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Rubytus::Mock

  def setup
    @server = app
  end

  def test_index
    get '/'
    assert_equal 404, last_response.status
  end

  def test_collection
    get '/uploads/'
    assert_equal 405, last_response.status
  end

  def test_resource_invalid_request_method
    put "/uploads/#{Rubytus::Uid.uid}"
    assert_equal 405, last_response.status
  end
end
