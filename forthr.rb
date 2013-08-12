class ForthR
  def initialize
    @s = []
    @out = []
    @words = {
      ".s"      => lambda { @out << @s.join(" ") },
      "."       => lambda { @out << @s.pop }, 
      "+"       => lambda { @s << @s.pop + @s.pop }, 
      "-"       => lambda { @s << -@s.pop + @s.pop }, 
      "*"       => lambda { @s << @s.pop * @s.pop }, 
      "/"       => lambda { y, x = @s.pop, @s.pop; @s << x / y },
      "negate"  => lambda { @s << -@s.pop }, 
      "mod"     => lambda { y, x = @s.pop, @s.pop; @s << x % y },
      "/mod"    => lambda { y, x = @s.pop, @s.pop; @s << x % y << x / y }, 
      "dup"     => lambda { @s << @s.last}, 
    }
  end

  def <<(line)
    tokenize(line).each do |command|
      @words[command] ? @words[command].call : push(command)
    end
  end

  def output
    @out.join("\n")
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
