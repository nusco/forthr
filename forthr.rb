class ForthR
  def initialize
    @s = []
    @out = ""
    @dictionary = {
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
      ":"       => lambda {
                     new_word = @words.shift.downcase
                     words = consume_up_to ";"
                     @dictionary[new_word] = lambda { words.each {|w| process w } }
                   },
    }
  end

  def execute_code(line)
    @words = line.split(" ")
    process @words.shift until @words.empty?
  end

  alias_method :<<, :execute_code

  def process(word)
    word = word.downcase
    if @dictionary[word]
      @dictionary[word].call
    else
      begin
        @s << Integer(word)
      rescue
        raise "Unknown word: #{word}"
      end
    end
  end

  def consume_up_to(word)
    result = []
    result << @words.shift until @words[0] == word
    @words.shift
    result
  end
  
  def output
    @out
  end

  def size
    @s.size
  end
end
