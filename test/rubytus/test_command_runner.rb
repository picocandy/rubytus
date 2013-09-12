require 'test_helper'
require 'fileutils'
require 'stringio'

class TestCommandRunner < MiniTest::Test
  include Rubytus::Mock
  include Goliath::TestHelper

  def setup
    @err = Proc.new { assert false, 'API request failed' }
  end

  def teardown
    remove_data_dir
  end

  def test_setup_exit_for_invalid_data_dir
    options = default_options.merge({
      :data_dir => '/opt/123='
    })

    is_exit = false

    begin
      capture_io do
        with_api(Rubytus::Command, options) {}
      end
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup_exit_for_invalid_data_dir_permission
    options = default_options.merge({
      :data_dir => '/root'
    })

    is_exit = false

    begin
      capture_io do
        with_api(Rubytus::Command, options) {}
      end
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup_exit_for_invalid_max_size
    options = {
      :data_dir => data_dir,
      :max_size => 'a'
    }

    is_exit = false

    begin
      capture_io do
        with_api(Rubytus::Command, options) {}
      end
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup_exit_for_invalid_base_path
    options = {
      :data_dir  => data_dir,
      :max_size  => 512,
      :base_path => '+foo+'
    }

    is_exit = false

    begin
      capture_io do
        with_api(Rubytus::Command, options) {}
      end
    rescue SystemExit
      is_exit = true
    end

    assert is_exit
  end

  def test_setup
    options = {
      :data_dir  => data_dir,
      :max_size  => '512',
      :base_path => '/uploads/'
    }

    with_api(Rubytus::Command, options) do |runner|
      opts = runner.api.instance_variable_get('@options')

      assert_kind_of Rubytus::Storage, opts[:storage]
      assert_equal 512, opts[:max_size]
      EM.stop
    end
  end

  def test_options_parser
    dir    = data_dir

    with_api(Rubytus::Command, default_options) do |runner|
      op = runner.api.options_parser(OptionParser.new, default_options)
      op.parse!(['-m', '512', '-f', dir, '-b', '/uploads/'])

      options = runner.api.instance_variable_get('@options')

      assert_equal dir, options[:data_dir]
      assert_equal '512', options[:max_size]
      assert_equal '/uploads/', options[:base_path]
      EM.stop
    end
  end
end
