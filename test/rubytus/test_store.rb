require 'test_helper'

class TestStore < MiniTest::Unit::TestCase
  def setup
    @configuration = Rubytus::Configuration.new(
      :data_dir  => "/tmp/rubytusd-#{rand(1000)}",
      :base_path => '/uploads/'
    )

    @read_only_configuration = Rubytus::Configuration.new(
      :data_dir  => "/opt/rubytus",
      :base_path => '/uploads/'
    )

    @configuration.validates!

    @uid   = Rubytus::Uid.uid
    @store = Rubytus::Store.new(@configuration)
  end

  def test_file_path
    assert_match "#{@uid}.bin", @store.file_path(@uid)
  end

  def test_info_path
    assert_match "#{@uid}.info", @store.info_path(@uid)
  end

  def test_write_file
    @store.write_file(@uid)
    assert_equal true, File.exist?(@store.file_path(@uid))
  end

  def test_write_file_failed
    store = Rubytus::Store.new(@read_only_configuration)
    assert_raises(Rubytus::PermissionError) { store.write_file(@uid) }
  end

  def test_write_info
    @store.write_info(@uid)
    assert_equal true, File.exist?(@store.info_path(@uid))
  end

  def test_write_info_failed
    store = Rubytus::Store.new(@read_only_configuration)
    assert_raises(Rubytus::PermissionError) { store.write_info(@uid) }
  end

  def test_create_file
    @store.create_file(@uid, 100)
    assert_equal true, File.exist?(@store.file_path(@uid))
    assert_equal true, File.exist?(@store.info_path(@uid))
  end
end
