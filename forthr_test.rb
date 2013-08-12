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
    assert_equal "3\n2\n1", @f.output
  end

  def test_addition
    @f << "1 2 + .s"
    assert_equal "3", @f.output
  end

  def test_subtraction
    @f << "3 2 - .s"
    assert_equal "1", @f.output
  end

  def test_multiplication
    @f << "3 2 * .s"
    assert_equal "6", @f.output
  end

  def test_division
    @f << "11 5 / .s"
    assert_equal "2", @f.output
  end

  def test_negation
    @f << "42 negate .s"
    assert_equal "-42", @f.output
  end

  def test_dup
    @f << "1 2 dup .s"
    assert_equal "1 2 2", @f.output
  end

  def test_stack_size
    @f << "1 2 3"
    assert_equal 3, @f.size
  end

  def test_unknown_word
    err = assert_raises RuntimeError do
      @f << "1 dup dum ehp"
    end
    assert_equal "Unknown word: dum", err.message
  end

  def test_case_insensitivity
    @f << "1 DUP dUp .S .s"
    assert_equal "1 1 1\n1 1 1", @f.output
  end
    
  def test_ignores_spaces
    @f << " 1  2    3  "
    assert_equal 3, @f.size
  end
end    
