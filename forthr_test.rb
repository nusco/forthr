require 'minitest/autorun'
require './forthr'

class TestStack < Minitest::Test
  def setup
    @f = ForthR.new
  end

  def test_dot_s
    @f << ".s 1 2 .s 3 .s"
    assert_equal " 1 2 1 2 3 ", @f.output
  end
  
  def test_dot
    @f << "1 2 3 . . .s"
    assert_equal "3 2 1 ", @f.output
  end

  def test_add
    @f << "1 2 + .s"
    assert_equal "3 ", @f.output
  end

  def test_subtract
    @f << "3 2 - .s"
    assert_equal "1 ", @f.output
  end

  def test_multiply
    @f << "3 2 * .s"
    assert_equal "6 ", @f.output
  end

  def test_divide
    @f << "11 5 / .s"
    assert_equal "2 ", @f.output
  end

  def test_negate
    @f << "42 negate .s"
    assert_equal "-42 ", @f.output
  end

  def test_mod
    @f << "8 3 mod .s"
    assert_equal "2 ", @f.output
  end

  def test_slash_mod
    @f << "7 3 /mod .s"
    assert_equal "1 2 ", @f.output
  end

  def test_dup
    @f << "1 2 dup .s"
    assert_equal "1 2 2 ", @f.output
  end

  def test_drop
    @f << "1 2 drop .s"
    assert_equal "1 ", @f.output
  end

  def test_swap
    @f << "1 2 3 swap .s"
    assert_equal "1 3 2 ", @f.output
  end

  def test_nip
    @f << "1 2 3 nip .s"
    assert_equal "1 3 ", @f.output
  end

  def test_tuck
    @f << "1 2 3 tuck .s"
    assert_equal "1 3 2 3 ", @f.output
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
    assert_equal "1 1 1 1 1 1 ", @f.output
  end
    
  def test_ignoring_spaces
    @f << " 1  2    3  "
    assert_equal 3, @f.size
  end
end    
