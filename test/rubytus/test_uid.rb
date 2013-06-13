require 'test_helper'

class TestUid < MiniTest::Unit::TestCase
  def test_uid
    assert_equal 32, Rubytus::Uid.uid.length
  end
end
