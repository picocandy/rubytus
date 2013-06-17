require 'test_helper'

class TestStore < MiniTest::Test
  include Rubytus::Mock

  def setup
    @configuration = Rubytus::Configuration.new(
      :data_dir  => data_dir,
      :base_path => '/uploads/'
    )

    @read_only_configuration = Rubytus::Configuration.new(
      :data_dir  => "/opt/rubytus",
      :base_path => '/uploads/'
    )

    @configuration.validates

    @uid   = uid
    @store = Rubytus::Store.new(@configuration)
  end

  def teardown
    remove_data_dir
  end

  def test_file_path
    assert_match "#{@uid}.bin", @store.file_path(@uid)
  end

  def test_info_path
    assert_match "#{@uid}.info", @store.info_path(@uid)
  end

  def test_write_file
    @store.write_file(@uid, '', 0)
    assert File.exist?(@store.file_path(@uid))
  end

  def test_write_file_failed
    store = Rubytus::Store.new(@read_only_configuration)
    assert_raises(Rubytus::PermissionError) { store.write_file(@uid, '', 0) }
  end

  def test_write_info
    @store.write_info(@uid, {})
    assert File.exist?(@store.info_path(@uid))
  end

  def test_write_info_failed
    store = Rubytus::Store.new(@read_only_configuration)
    assert_raises(Rubytus::PermissionError) { store.write_info(@uid, {}) }
  end

  def test_create_file
    @store.create_file(@uid, final_length: 100)
    assert File.exist?(@store.file_path(@uid))
    assert File.exist?(@store.info_path(@uid))
  end

  def test_read_info
    stub(IO).read(@store.info_path(@uid)) { '{"Offset":100,"FinalLength":500,"Meta":null}' }
    output = @store.read_info(@uid)
    assert_kind_of Hash, output
    assert_equal 100, output['Offset']
  end

  def test_read_info_failure
    stub(@store).info_path(@uid) { '/opt/rubytus/non-exist' }
    assert_raises(Rubytus::PermissionError) { @store.read_info(@uid) }
  end
end
