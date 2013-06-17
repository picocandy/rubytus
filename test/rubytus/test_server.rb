require 'test_helper'

class TestServer < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  include Rubytus::Mock

  def setup
    @server = app
  end

  def teardown
    remove_data_dir
  end

  def collection_path
    '/uploads/'
  end

  def resource_path(uid)
    "/uploads/#{uid}"
  end

  def test_index
    get '/'
    assert_equal 404, last_response.status
  end

  def test_collection_via_get
    get collection_path
    assert_equal 405, last_response.status
  end

  def test_collection_options
    options collection_path
  end

  def test_resource_invalid_request_method
    put resource_path(uid)
    assert_equal 405, last_response.status
  end

  def test_patch_resource
    patch resource_path(uid), 'file' => Rack::Test::UploadedFile.new(pdf)
  end
end
