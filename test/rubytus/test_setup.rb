require 'test_helper'
require 'fileutils'
require 'stringio'

class TestConfiguration < MiniTest::Test
  include Rubytus::Mock

  def setup
    @config = Rubytus::Mock::Config.new
  end

  def teardown
    remove_data_dir
  end

  def test_validate_data_dir
    dir = @config.validate_data_dir(data_dir)
    assert File.directory?(dir)
  end

  def test_validate_data_dir_world_writable
    dir = @config.validate_data_dir(data_dir)
    assert_equal "777", sprintf("%o", File.world_writable?(dir))
  end

  def test_validate_data_dir_permission_error
    assert_raises(Rubytus::PermissionError) { @config.validate_data_dir('/opt/rubytus') }
  end

  def test_validate_max_size_blank
    assert_raises(Rubytus::ConfigurationError) { @config.validate_max_size('') }
  end

  def test_validate_max_size_string
    assert_equal 512, @config.validate_max_size('512')
  end

  def test_validate_base_path_error
    assert_raises(Rubytus::ConfigurationError) { @config.validate_base_path('abc+def=gh') }
  end

  def test_validate_base_path
    assert_equal '/user-uploads/', @config.validate_base_path('/user-uploads/')
  end

  def test_setup_exit_for_invalid_data_dir
    config = @config.dup
    config.instance_variable_set('@options', { :data_dir => '/opt/123=' })
    is_exit = false

    begin
      capture_io { config.setup }
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup_exit_for_invalid_max_size
    config = @config.dup
    config.instance_variable_set('@options', {
      :data_dir => data_dir,
      :max_size => 'a'
    })

    is_exit = false

    begin
      capture_io { config.setup }
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup_exit_for_invalid_base_path
    config = @config.dup
    config.instance_variable_set('@options', {
      :data_dir  => data_dir,
      :max_size  => 512,
      :base_path => '+foo+'
    })

    is_exit = false

    begin
      capture_io { config.setup }
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup
    config = @config.dup
    config.instance_variable_set('@options', {
      :data_dir  => data_dir,
      :max_size  => '512',
      :base_path => '/uploads/'
    })

    config.setup

    opts = config.instance_variable_get('@options')

    assert_kind_of Rubytus::Storage, config.instance_variable_get('@storage')
    assert_equal 512, opts[:max_size]
  end

  def test_init_storage
    config  = @config.dup
    options = config.init_options

    assert_kind_of Rubytus::Storage, config.init_storage(options)
  end

  def test_options_parser
    config = @config.dup
    dir    = data_dir

    op = config.options_parser(OptionParser.new, default_options)
    op.parse!(['-m', '512', '-f', dir, '-b', '/uploads/'])

    options = config.instance_variable_get('@options')

    assert_equal dir, options[:data_dir]
    assert_equal '512', options[:max_size]
    assert_equal '/uploads/', options[:base_path]
  end
end
