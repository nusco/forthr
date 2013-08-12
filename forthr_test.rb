require 'minitest/autorun'
require './forthr'

class TestStack < Minitest::Test
  def setup
    @f = ForthR.new
  end

  def test_inserts
    @f << "1 2 3"
    assert_equal 3, @f.size
  end

  def test_ignores_spaces
    @f << " 1  2    3  "
    assert_equal 3, @f.size
  end
end    
