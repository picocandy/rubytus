require 'test_helper'
require 'rubytus/command'
require 'rubytus/info'

class TestRubytusCommand < MiniTest::Test
  include Rubytus::Mock
  include Rubytus::StorageHelper
  include Goliath::TestHelper

  def setup
    @err = Proc.new { assert false, 'API request failed' }
  end

  def protocol_header
    { 'TUS-Resumable' => '1.0.0' }
  end

  def test_get_request_for_root
    params = { :path => '/' }

    with_api(Rubytus::Command, default_options) do
      get_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_NOT_FOUND, c.response_header.status
      end
    end
  end

  def test_supported_version
    params = {
      :path => '/uploads/',
      :head => { 'TUS-Resumable' => '0.0.1' }
    }

    with_api(Rubytus::Command, default_options) do
      options_request(params, @err) do |c|
        assert_equal STATUS_PRECONDITION_FAILED, c.response_header.status
        assert_error_message 'Unsupported version: 0.0.1. Please use: 1.0.0.', c.response
      end
    end
  end

  def test_options_request_for_collection
    params = {
      :path => '/uploads/',
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      options_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_tus_extensions c.response_header, SUPPORTED_EXTENSIONS
        assert_tus_max_size c.response_header, (1024 * 1024)
        assert_equal STATUS_NO_CONTENT, c.response_header.status
      end
    end
  end

  def test_options_request_for_collection_cors
    params = {
      :path => '/uploads/',
      :head => protocol_header.merge({ 'Origin' => 'picocandy.io' })
    }

    with_api(Rubytus::Command, default_options) do
      options_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_tus_extensions c.response_header, SUPPORTED_EXTENSIONS
        assert_tus_max_size c.response_header, (1024 * 1024)
        assert_tus_cors_option c.response_header, 'picocandy.io'
        assert_equal STATUS_NO_CONTENT, c.response_header.status
      end
    end
  end

  def test_get_request_for_collection
    params = {
      :path => '/uploads/',
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      get_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_NOT_ALLOWED, c.response_header.status
        assert_equal 'POST', c.response_header['ALLOW']
      end
    end
  end

  def test_post_request_for_collection_without_entity_length
    params = {
      :path => '/uploads/',
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      post_request(params, @err) do |c|
        assert_equal STATUS_BAD_REQUEST, c.response_header.status
      end
    end
  end

  def test_post_request_for_collection_with_negative_entity_length
    params = {
      :path => '/uploads/',
      :head => protocol_header.merge({ 'Entity-Length' => '-1'})
    }

    with_api(Rubytus::Command, default_options) do
      post_request(params, @err) do |c|
        assert_equal STATUS_BAD_REQUEST, c.response_header.status
        assert_error_message "Invalid Entity-Length: -1. It should non-negative integer or string 'streaming'", c.response
      end
    end
  end

  def test_post_request_for_collection_with_wrong_metadata
    params = {
      :path => '/uploads/',
      :head => protocol_header.merge({
        'Entity-Length' => '10',
        'Metadata'     => 'this-is-wrong'
      })
    }

    with_api(Rubytus::Command, default_options) do
      post_request(params, @err) do |c|
        assert_equal STATUS_BAD_REQUEST, c.response_header.status
        assert_error_message 'Metadata must be a key-value pair', c.response
      end
    end
  end

  def test_post_request_for_collection_with_metadata
    params = {
      :path => '/uploads/',
      :head => protocol_header.merge({
        'Entity-Length' => '10',
        'Metadata'     => ['filename', encode64('awesome-file.png'), 'mimetype', encode64('image/png')].join(' ')
      })
    }

    with_api(Rubytus::Command, default_options) do
      post_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_CREATED, c.response_header.status
        assert c.response_header.location
      end
    end
  end

  def test_post_request_for_collection_with_cors
    params = {
      :path => '/uploads/',
      :head => protocol_header.merge({
        'Entity-Length' => '10',
        'Origin'        => 'picocandy.io'
      })
    }

    with_api(Rubytus::Command, default_options) do
      post_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_tus_cors_expose c.response_header
        assert_equal STATUS_CREATED, c.response_header.status
        assert c.response_header.location
      end
    end
  end

  def test_post_request_for_collection
    params = {
      :path => '/uploads/',
      :head => protocol_header.merge({ 'Entity-Length' => '10' })
    }

    with_api(Rubytus::Command, default_options) do
      post_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_CREATED, c.response_header.status
        assert c.response_header.location
      end
    end
  end

  def test_put_request_for_resource
    params = {
      :path => "/uploads/#{uid}",
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      put_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal 405, c.response_header.status
        assert_equal 'HEAD,PATCH', c.response_header['ALLOW']
      end
    end
  end

  def test_patch_request_for_resource_without_valid_content_type
    params = {
      :path => "/uploads/#{uid}",
      :body => 'abc',
      :head => protocol_header.merge({
        'Offset'        => '0',
        'Entity-Length' => '3',
        'Content-Type'  => 'plain/text'
      })
    }

    with_api(Rubytus::Command, default_options) do
      patch_request(params, @err) do |c|
        assert_equal STATUS_BAD_REQUEST, c.response_header.status
      end
    end
  end

  def test_patch_request_for_resource
    options = default_options
    ruid    = uid

    validates_data_dir(options[:data_dir])

    storage = Rubytus::Storage.new(options)
    storage.create_file(ruid, 3)

    params = {
      :path => "/uploads/#{ruid}",
      :body => 'abc',
      :head => protocol_header.merge({
        'Offset'        => '0',
        'Entity-Length' => '3',
        'Content-Type'  => 'application/offset+octet-stream'
      })
    }

    with_api(Rubytus::Command, options) do
      patch_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_OK, c.response_header.status
      end
    end
  end

  def test_patch_request_for_resource_exceed_offset
    ruid = uid
    info = Rubytus::Info.new(:offset => 0)

    any_instance_of(Rubytus::Storage) do |klass|
      stub(klass).read_info(ruid) { info }
    end

    params = {
      :path => "/uploads/#{ruid}",
      :body => 'abc',
      :head => protocol_header.merge({
        'Offset'        => '3',
        'Entity-Length' => '3',
        'Content-Type'  => 'application/offset+octet-stream'
      })
    }

    with_api(Rubytus::Command, default_options) do
      patch_request(params, @err) do |c|
        assert_equal STATUS_FORBIDDEN, c.response_header.status
      end
    end
  end

  def test_patch_request_for_resource_exceed_remaining_length
    ruid = uid
    info = Rubytus::Info.new(:offset => 0, :entity_length => 2)

    any_instance_of(Rubytus::Storage) do |klass|
      stub(klass).read_info(ruid) { info }
    end

    params = {
      :path => "/uploads/#{ruid}",
      :body => 'abcdef',
      :head => protocol_header.merge({
        'Offset'        => '0',
        'Entity-Length' => '6',
        'Content-Type'  => 'application/offset+octet-stream'
      })
    }

    with_api(Rubytus::Command, default_options) do
      patch_request(params, @err) do |c|
        assert_equal STATUS_FORBIDDEN, c.response_header.status
      end
    end
  end

  def test_patch_request_for_resource_failure
    options = read_only_options
    params  = {
      :path => "/uploads/#{uid}",
      :body => 'abc',
      :head => protocol_header.merge({
        'Offset'        => '0',
        'Entity-Length' => '3',
        'Content-Type'  => 'application/offset+octet-stream'
      })
    }

    any_instance_of(Rubytus::Command) do |klass|
      stub(klass).setup { true }
      stub(klass).storage { Rubytus::Storage.new(options) }
    end

    with_api(Rubytus::Command, options) do
      patch_request(params, @err) do |c|
        assert_equal STATUS_INTERNAL_ERROR, c.response_header.status
      end
    end
  end

  def test_head_request_for_resource
    ruid = uid
    info = Rubytus::Info.new(:offset => 3)

    any_instance_of(Rubytus::Storage) do |klass|
      stub(klass).read_info(ruid) { info }
    end

    params = {
      :path => "/uploads/#{ruid}",
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      head_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_OK, c.response_header.status
        assert_equal '3', c.response_header['OFFSET']
      end
    end
  end

  def test_head_request_for_unknown_resource
    ruid = uid

    any_instance_of(Rubytus::Storage) do |klass|
      stub(klass).read_info(ruid) { nil }
    end

    params = {
      :path => "/uploads/#{ruid}",
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      head_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_NOT_FOUND, c.response_header.status
        assert_equal nil, c.response_header['OFFSET']
      end
    end
  end

  def test_get_request_for_resource_failure
    ruid = uid

    any_instance_of(Rubytus::Storage) do |klass|
      stub(klass).read_file(ruid) { raise Rubytus::PermissionError }
    end

    params = {
      :path => "/uploads/#{ruid}",
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      get_request(params, @err) do |c|
        assert_equal STATUS_INTERNAL_ERROR, c.response_header.status
      end
    end
  end

  def test_get_request_for_resource
    ruid = uid

    any_instance_of(Rubytus::Storage) do |klass|
      stub(klass).read_file(ruid) { 'abc' }
    end

    params = {
      :path => "/uploads/#{ruid}",
      :head => protocol_header
    }

    with_api(Rubytus::Command, default_options) do
      get_request(params, @err) do |c|
        assert_tus_protocol c.response_header
        assert_equal STATUS_OK, c.response_header.status
        assert_equal 'abc', c.response
      end
    end
  end
end
