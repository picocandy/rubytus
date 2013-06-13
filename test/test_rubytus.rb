require "test_helper"

class TestRubytus < MiniTest::Unit::TestCase
  def test_version
    assert_equal "0.0.1", Rubytus::VERSION
  end
end
