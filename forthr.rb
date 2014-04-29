class ForthR
  def initialize
    @s = []
    @out = ""
    @words = {
      ".s"      => Word.new(".s")     { @out << "#{@s.join(' ')} " },
      "."       => Word.new(".")      { @out << "#{@s.pop} " },
      "+"       => Word.new("+")      { @s << @s.pop + @s.pop },
      "-"       => Word.new("-")      { @s << -@s.pop + @s.pop },
      "*"       => Word.new("*")      { @s << @s.pop * @s.pop },
      "/"       => Word.new("/")      { y, x = @s.pop, @s.pop; @s << x / y },
      "negate"  => Word.new("negate") { @s << -@s.pop },
      "mod"     => Word.new("mod")    { y, x = @s.pop, @s.pop; @s << x % y },
      "/mod"    => Word.new("/mod")   { y, x = @s.pop, @s.pop; @s << x % y << x / y },
      "dup"     => Word.new("dup")    { @s << @s.last},
      "drop"    => Word.new("drop")   { @s.pop },
      "swap"    => Word.new("swap")   { y, x = @s.pop, @s.pop; @s << y << x },
      "nip"     => Word.new("nip")    { y, x = @s.pop, @s.pop; @s << y },
      "tuck"    => Word.new("tuck")   { y, x = @s.pop, @s.pop; @s << y << x << y },
      "("       => Word.new("(")      { consume_until ")" },
      "\\"      => Word.new("\\")     { @code.clear },
      ":"       => Word.new(":")      {
                     defined_word = @code.shift.downcase
                     code = consume_until ";"
                     expanded_code = code.map {|w| compile w }.flatten
                     definition = CompositeWord.new(expanded_code, method(:process))
                     @words[defined_word] = definition
                   },
      "see"     => Word.new("see")  { @out << decompile(@code.shift) },
      "bye"     => Word.new("bye")  { exit },
    }
  end

  def <<(line)
    @code = line.split(" ")
    process @code.shift until @code.empty?
  end

  def process(word)
    word = word.downcase
    if @words[word]
      @words[word].call
    else
      begin
        @s << Integer(word)
      rescue
        raise "<Undefined word: #{word}>"
      end
    end
  end

  def compile(word)
    return @words[word].map {|w| compile w }.flatten if @words[word].class == CompositeWord
    word
  end

  def decompile(word)
    test_word = @words[word]
    return test_word.decompile if test_word.class == CompositeWord
    return "<Undefined word: #{word}>" unless test_word

    "<primitive>"
  end

  def consume_until(terminator)
    result = []
    result << @code.shift until @code.first == terminator
    @code.shift
    result
  end

  def read
    result = @out
    @out = ""
    result
  end

  def size; @s.size; end

  class Word < Proc
    def initialize(name, &block)
      @name = name
      super &block
    end

    def decompile
      "<Undefined word: #{to_s}>"
    end
  end

  class CompositeWord < Struct.new(:expanded_code, :process)

    include Enumerable

    def each(&block)
      expanded_code.each &block
    end

    def join(*args)
      expanded_code.join(*args)
    end

    def decompile
      expanded_code.join(" ") + " ; "
    end

    def call
      expanded_code.each {|w| process.call w }
    end
  end
end
