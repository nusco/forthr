class ForthR
  def initialize
    @s = []
    @out = ""
    @definitions = {}
    @primitives = {
      ".s"      => lambda { @out << "#{@s.join(' ')} " },
      "."       => lambda { @out << "#{@s.pop} " },
      "+"       => lambda { @s << @s.pop + @s.pop },
      "-"       => lambda { @s << -@s.pop + @s.pop },
      "*"       => lambda { @s << @s.pop * @s.pop },
      "/"       => lambda { y, x = @s.pop, @s.pop; @s << x / y },
      "negate"  => lambda { @s << -@s.pop },
      "mod"     => lambda { y, x = @s.pop, @s.pop; @s << x % y },
      "/mod"    => lambda { y, x = @s.pop, @s.pop; @s << x % y << x / y },
      "dup"     => lambda { @s << @s.last},
      "drop"    => lambda { @s.pop },
      "swap"    => lambda { y, x = @s.pop, @s.pop; @s << y << x },
      "nip"     => lambda { y, x = @s.pop, @s.pop; @s << y },
      "tuck"    => lambda { y, x = @s.pop, @s.pop; @s << y << x << y },
      "("       => lambda { consume_until ")" },
      "\\"      => lambda { @words.clear },
      ":"       => lambda {
                     new_word = @words.shift.downcase
                     code = consume_until ";"
                     @definitions[new_word] = code.map {|w| compile w }.flatten
                   },
      "see"     => lambda { @out << decompile(@words.shift) },
    }
  end

  def <<(line)
    @words = line.split(" ")
    process @words.shift until @words.empty?
  end

  def process(word)
    word = word.downcase
    if @definitions[word]
      @definitions[word].each {|w| process w }
    elsif @primitives[word]
      @primitives[word].call
    else
      begin
        @s << Integer(word)
      rescue
        raise "<Undefined word: #{word}>"
      end
    end
  end

  def compile(word)
    return @definitions[word].map {|w| compile w }.flatten if @definitions[word]
    word
  end

  def decompile(word)
    return "#{@definitions[word].join(' ')} ; " if @definitions[word]
    return "<primitive>" if @primitives[word]
    "<Undefined word: #{word}>"
  end
  
  def consume_until(terminator)
    result = []
    result << @words.shift until @words.first == terminator
    @words.shift
    result
  end
  
  def dump
    result = @out
    @out = ""
    result
  end
  
  def size; @s.size; end
end
