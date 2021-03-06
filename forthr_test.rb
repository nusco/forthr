require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use!

require './forthr'

class TestStack < Minitest::Test
  def setup
    @f = ForthR::Interpreter.new
  end

  def test_dot_s
    @f << ".s 1 2 .s 3 .s"
    assert_equal " 1 2 1 2 3 ", @f.read
  end

  def test_dot
    @f << "1 2 3 . . .s"
    assert_equal "3 2 1 ", @f.read
  end

  def test_add
    @f << "1 2 + .s"
    assert_equal "3 ", @f.read
  end

  def test_subtract
    @f << "3 2 - .s"
    assert_equal "1 ", @f.read
  end

  def test_multiply
    @f << "3 2 * .s"
    assert_equal "6 ", @f.read
  end

  def test_divide
    @f << "11 5 / .s"
    assert_equal "2 ", @f.read
  end

  def test_negate
    @f << "42 negate .s"
    assert_equal "-42 ", @f.read
  end

  def test_mod
    @f << "8 3 mod .s"
    assert_equal "2 ", @f.read
  end

  def test_slash_mod
    @f << "7 3 /mod .s"
    assert_equal "1 2 ", @f.read
  end

  def test_dup
    @f << "1 2 dup .s"
    assert_equal "1 2 2 ", @f.read
  end

  def test_drop
    @f << "1 2 drop .s"
    assert_equal "1 ", @f.read
  end

  def test_swap
    @f << "1 2 3 swap .s"
    assert_equal "1 3 2 ", @f.read
  end

  def test_nip
    @f << "1 2 3 nip .s"
    assert_equal "1 3 ", @f.read
  end

  def test_tuck
    @f << "1 2 3 tuck .s"
    assert_equal "1 3 2 3 ", @f.read
  end

  def test_define_word
    @f << ": sequence dup 1 + ;"
    @f << "5 sequence .s"
    assert_equal "5 6 ", @f.read
  end

  def test_redefine_word
    @f << ": do 1 ;"
    @f << "do"
    @f << ": do 2 ;"
    @f << "do .s"
    assert_equal "1 2 ", @f.read
  end

  def test_compiled_calls
    @f << ": oneone 1 dup ;"
    @f << ": oneonetwo oneone 2 ;"
    @f << "oneonetwo"
    @f << ": oneone 3 ;"
    @f << "oneonetwo .s"
    assert_equal "1 1 2 1 1 2 ", @f.read
  end

  def test_unknown_words_do_not_compile
    err = assert_raises RuntimeError do
      @f << ": wrong blah ;"
    end
  end

  def test_see_primitive_word
    @f << "see drop"
    assert_match /^<primitive>/, @f.read
  end

  def test_see_defined_word
    @f << ": sequence dup 1 ;"
    @f << ": longersequence drop sequence + ;"
    @f << "see longersequence"
    assert_equal "drop sequence + ; ", @f.read
  end

  def test_see_undefined_word
    @f << "see blah"
    assert_equal ":blah: <Undefined word>", @f.read
  end

  def test_see_integer
    @f << "see 1"
    assert_equal ":1: <Undefined word>", @f.read
  end

  def test_parenthesized_comments
    @f << "1 2 ( ignore this ) 3 .s"
    assert_equal "1 2 3 ", @f.read
  end

  def test_backslashed_comments
    @f << "1 2 \\ ignore this"
    @f << ".s"
    assert_equal "1 2 ", @f.read
  end

  def test_stack_size
    @f << "1 2 3"
    assert_equal 3, @f.size
  end

  def test_undefined_word
    err = assert_raises RuntimeError do
      @f << "1 dup dum ehp"
    end
    assert_equal ":dum: <Undefined word>", err.message
  end

  def test_ignore_case
    @f << "1 DUP dUp .S .s"
    assert_equal "1 1 1 1 1 1 ", @f.read
  end

  def test_ignore_spaces
    @f << " 1  2    3  "
    assert_equal 3, @f.size
  end

  def test_ignore_newlines
    @f << "1 2 \n 3 .s"
    assert_equal "1 2 3 ", @f.read
  end

  def test_read
    @f << "1 2 .s"
    assert_equal "1 2 ", @f.read
    @f << "3"
    assert_equal "", @f.read
    @f << ".s"
    assert_equal "1 2 3 ", @f.read
  end

  def test_false
    @f << "false .s"
    assert_equal "0 ", @f.read
  end

  def test_true
    @f << "true .s"
    assert_equal "-1 ", @f.read
  end

  def test_equality
    @f << "1 1 = .s"
    assert_equal "-1 ", @f.read
  end

  def test_not_equality
    @f << "1 0 = .s"
    assert_equal "0 ", @f.read
  end

  def test_store_and_fetch
    @f << "42 100 !"
    @f << "100 @ .s"
    assert_equal "42 ", @f.read
  end

  def test_variable_declaration
    @f << "variable foo"
    @f << "foo @ .s"
    assert_equal "0 ", @f.read
  end

  def test_variable_address_on_stack
    @f << "variable foo"
    @f << "variable bar"
    @f << "foo bar .s"
    assert_equal "0 1 ", @f.read
  end

  def test_variable_see
    @f << "variable foo"
    @f << "see foo"
    assert_equal "Variable foo", @f.read
  end

  def test_variable_store_and_fetch
    @f << "variable foo"
    @f << "42 foo !"
    @f << "foo @ .s"
    assert_equal "42 ", @f.read
  end

  def test_basic_counted_loop
    @f << "4 1 ?do 2 1 + . loop"
    assert_equal "3 3 3 ", @f.read
  end
end
