require 'minitest/autorun'
require './forthr'

class TestStack < Minitest::Test
  def setup
    @f = ForthR.new
  end

  def test_dot_s_word
    @f << ".s 1 2 .s 3 .s"
    assert_equal "\n1 2\n1 2 3", @f.output
  end
  
  def test_dot_word
    @f << "1 2 3 . . .s"
    assert_equal "1", @f.output
  end

  def test_dup
    @f << "1 2 dup .s"
    assert_equal "1 2 2", @f.output
  end

  def test_stack_size
    @f << "1 2 3"
    assert_equal 3, @f.size
  end

  def test_case_insensitivity
    @f << "1 DUP dup .S .s"
    assert_equal "1 1 1\n1 1 1", @f.output
  end
    
  def test_ignores_spaces
    @f << " 1  2    3  "
    assert_equal 3, @f.size
  end
end    
