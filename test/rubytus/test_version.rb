require 'test_helper'

class TestVersion < MiniTest::Unit::TestCase
  def test_version
    refute_nil Rubytus::VERSION
  end
end
