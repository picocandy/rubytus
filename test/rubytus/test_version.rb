require 'test_helper'

class TestVersion < MiniTest::Test
  def test_version
    refute_nil Rubytus::VERSION
  end
end
