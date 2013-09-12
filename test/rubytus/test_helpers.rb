require 'test_helper'
require 'fileutils'
require 'stringio'

class TestHelpers < MiniTest::Test
  include Rubytus::Mock

  def setup
    @config = Rubytus::Mock::Config.new
  end

  def teardown
    remove_data_dir
  end

  def test_validates_data_dir
    dir = @config.validates_data_dir(data_dir)
    assert File.directory?(dir)
  end

  def test_validates_data_dir_world_writable
    dir = @config.validates_data_dir(data_dir)
    assert_equal "777", sprintf("%o", File.world_writable?(dir))
  end

  def test_validates_data_dir_relative_path
    config = @config.dup
    dir    = "rubytus-#{rand(1000)}"
    assert_equal dir, File.basename(config.validates_data_dir(dir))
    assert_equal "777", sprintf("%o", File.world_writable?(dir))
    FileUtils.rm_rf(dir)
  end

  def test_validates_data_dir_permission_error
    assert_raises(Rubytus::PermissionError) { @config.validates_data_dir('/opt/rubytus') }
  end

  def test_validates_max_size_blank
    assert_raises(Rubytus::ConfigurationError) { @config.validates_max_size('') }
  end

  def test_validates_max_size_string
    assert_equal 512, @config.validates_max_size('512')
  end

  def test_validates_base_path_error
    assert_raises(Rubytus::ConfigurationError) { @config.validates_base_path('abc+def=gh') }
  end

  def test_validates_base_path
    assert_equal '/user-uploads/', @config.validates_base_path('/user-uploads/')
  end

  def test_uid
    assert_equal 32, (@config.generate_uid).length
  end
end
