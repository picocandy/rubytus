require 'test_helper'
require 'time'

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

  def test_method_not_allowed
    @response.method_not_allowed
    assert_equal 405, @response.status
  end

  def test_not_found
    @response.not_found
    assert_equal 404, @response.status
  end

  def test_bad_request
    @response.bad_request
    assert_equal 400, @response.status
  end

  def test_server_error
    @response.server_error
    assert_equal 500, @response.status
  end

  def test_created
    @response.created
    assert_equal 201, @response.status
  end

  def test_ok
    @response.ok
    assert_equal 200, @response.status
  end

  def test_date
    the_time = Time.mktime(2013, 6, 15)
    stub(Time).now { the_time }

    response = Rubytus::Response.new
    response.date

    assert_equal the_time.httpdate, response.headers['Date']
  end

  def test_date_which_exist_on_header
    the_time = Time.mktime(2013, 6, 15)
    @response.headers['Date'] = the_time.httpdate.to_s
    assert_equal the_time, @response.date
  end
end
