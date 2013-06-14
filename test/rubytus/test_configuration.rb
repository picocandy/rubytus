require 'test_helper'
require 'fileutils'

class TestConfiguration < MiniTest::Unit::TestCase
  def test_initialize_with_options
    configuration = Rubytus::Configuration.new(:base_path => '/uploads/')
    assert_equal '/uploads/', configuration.base_path
  end

  def test_initialize_with_env
    ENV['TUSD_BASE_PATH'] = '/uploads/'

    configuration = Rubytus::Configuration.new
    assert_equal '/uploads/', configuration.base_path
  end

  def test_validate_data_dir
    random_name   = "/tmp/rubytus-#{rand(10000)}"
    configuration = Rubytus::Configuration.new(:data_dir => random_name)
    configuration.validate_data_dir

    assert_equal true, File.directory?(configuration.data_dir)

    FileUtils.rm_rf configuration.data_dir # cleanup
  end

  def test_validate_data_dir_permission_error
    configuration = Rubytus::Configuration.new(:data_dir => '/opt/rubytus')
    assert_raises(Rubytus::PermissionError) { configuration.validate_data_dir }
  end

  def test_validate_max_size_blank
    configuration = Rubytus::Configuration.new(:max_size => '')
    assert_raises(Rubytus::ConfigurationError) { configuration.validate_max_size }
  end

  def test_validate_max_size_with_env
    ENV['TUSD_MAX_SIZE'] = '102400'

    configuration = Rubytus::Configuration.new
    configuration.validate_max_size
    assert_equal 102400, configuration.max_size
  end

  def test_validate_base_path_error
    configuration = Rubytus::Configuration.new(:base_path => 'abc+def=gh')
    assert_raises(Rubytus::ConfigurationError) { configuration.validate_base_path }
  end

  def test_validate_base_path
    configuration = Rubytus::Configuration.new(:base_path => '/user-uploads/')
    assert_equal '/user-uploads/', configuration.base_path
  end

  def test_validates!
    random_name   = "/tmp/rubytus-#{rand(10000)}"
    configuration = Rubytus::Configuration.new(:data_dir => random_name)
    assert_equal nil, configuration.validates!
  end
end
