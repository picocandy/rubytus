require 'test_helper'

class TestResponse < MiniTest::Unit::TestCase
  def setup
    @response = Rubytus::Response.new
  end

  def test_initialize
    assert_equal 'text/plain; charset=utf-8', @response.headers['Content-Type']
    assert_equal '*', @response.header['Access-Control-Allow-Origin']

    assert_equal 'HEAD,GET,PUT,POST,PATCH,DELETE',
      @response.header['Access-Control-Allow-Methods']

    assert_equal 'Origin, X-Requested-With, Content-Type, Accept, Content-Disposition, Final-Length, Offset',
      @response.header['Access-Control-Allow-Headers']

    assert_equal 'Location, Range, Content-Disposition, Offset',
      @response.header['Access-Control-Expose-Headers']
  end

  def test_method_not_allowed!
    response = Rubytus::Response.new
    response.method_not_allowed!
    assert_equal 405, response.status
  end

  def test_not_found!
    response = Rubytus::Response.new
    response.not_found!
    assert_equal 404, response.status
  end

  def test_bad_request!
    response = Rubytus::Response.new
    response.bad_request!
    assert_equal 400, response.status
  end

  def test_server_error!
    response = Rubytus::Response.new
    response.server_error!
    assert_equal 500, response.status
  end

  def test_created!
    response = Rubytus::Response.new
    response.created!
    assert_equal 201, response.status
  end
end
