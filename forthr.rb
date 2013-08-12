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
    }
  end

  def <<(line)
    tokenize(line).each do |command|
      @dictionary[command] ? @dictionary[command].call : push(command)
    end
  end

  def output
    @out
  end

  def push(command)
    @s << Integer(command)
  rescue
    raise "Unknown word: #{command}"
  end

  def size
    @s.size
  end

  def tokenize(line)
    line.split(" ").map {|word| word.downcase }
  end
end
