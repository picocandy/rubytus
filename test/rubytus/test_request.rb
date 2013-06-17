require 'test_helper'
require 'rack/mock'

class TestRequest < MiniTest::Test
  include Rubytus::Mock

  def setup
    @configuration = Rubytus::Configuration.new(
      :data_dir  => data_dir,
      :base_path => '/uploads/'
    )

    @root_env       = Rack::MockRequest.env_for('http://example.com:8080/')
    @collection_env = Rack::MockRequest.env_for('http://example.com:8080/uploads/')
    @resource_env   = Rack::MockRequest.env_for('http://example.com:8080/uploads/823c29ccdce3075e7d20c5b2811b88d9')
  end

  def teardown
    remove_data_dir
  end

  def test_unknown
    request = Rubytus::Request.new(@root_env, @configuration)
    assert request.unknown?
  end

  def test_collection
    request = Rubytus::Request.new(@collection_env, @configuration)
    assert request.collection?
  end

  def test_resource
    request = Rubytus::Request.new(@resource_env, @configuration)
    assert request.resource?
  end

  def test_resource_name
    request = Rubytus::Request.new(@resource_env, @configuration)
    assert_equal '823c29ccdce3075e7d20c5b2811b88d9', request.resource_name
  end

  def test_final_length
    mock_env = Rack::MockRequest.env_for('/', 'HTTP_HOST' => 'localhost:8080', 'HTTP_FINAL_LENGTH' => '102400')
    request  = Rubytus::Request.new(mock_env, @configuration)
    assert_equal 102400, request.final_length
  end

  def test_final_length_error
    mock_env = Rack::MockRequest.env_for('/', 'HTTP_HOST' => 'localhost:8080', 'HTTP_FINAL_LENGTH' => '-100')
    request  = Rubytus::Request.new(mock_env, @configuration)
    assert_raises(Rubytus::HeaderError) { request.final_length }
  end

  def test_offset
    mock_env = Rack::MockRequest.env_for('/', 'HTTP_HOST' => 'localhost:8080', 'HTTP_OFFSET' => '20')
    request  = Rubytus::Request.new(mock_env, @configuration)
    assert_equal 20, request.offset
  end

  def test_offset_error
    mock_env = Rack::MockRequest.env_for('/', 'HTTP_HOST' => 'localhost:8080', 'HTTP_OFFSET' => 'abc')
    request  = Rubytus::Request.new(mock_env, @configuration)
    assert_raises(Rubytus::HeaderError) { request.offset }
  end

  def test_resource_url
    mock_env = Rack::MockRequest.env_for('/', 'SERVER_NAME' => 'localhost', 'SERVER_PORT' => '8080', 'HTTP_SCHEME' => 'http')
    request  = Rubytus::Request.new(mock_env, @configuration)
    expected = 'http://localhost:8080/uploads/823c29ccdce3075e7d20c5b2811b88d9'
    assert_equal expected, request.resource_url('823c29ccdce3075e7d20c5b2811b88d9')
  end
end
