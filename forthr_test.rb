require 'minitest/autorun'
require './forthr'

class TestStack < Minitest::Test
  def setup
    @f = ForthR.new
  end

  def test_prints_stack
    @f << "1 2 3 .s 4"
    assert_equal "1 2 3", @f.output
  end
  
  def test_dot_word
    @f << "1 2 3 . . .s"
    assert_equal "1", @f.output
  end

  def test_knows_stack_size
    @f << "1 2 3"
    assert_equal 3, @f.size
  end

  def test_ignores_spaces
    @f << " 1  2    3  "
    assert_equal 3, @f.size
  end
end    
