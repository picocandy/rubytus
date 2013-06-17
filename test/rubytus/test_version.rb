require 'test_helper'

class TestVersion < MiniTest::Test
  def test_version
    refute_nil Rubytus::VERSION
  end

  def test_version_frozen
    assert Rubytus::VERSION.frozen?
  end
end
