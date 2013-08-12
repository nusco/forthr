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
      "/"       => lambda { div = @s.pop; @s << @s.pop / div}, 
      "negate"  => lambda { @s << -@s.pop }, 
      "dup"     => lambda { @s << @s.last}, 
    }
  end

  def <<(line)
    tokenize(line).each do |command|
      if @words[command]
        @words[command].call
      else
        begin
          @s << Integer(command)
        rescue
          raise "Unknown word: #{command}"
        end
      end
    end
  end

  def output
    @out.join("\n")
  end

  def size
    @s.size
  end

  def tokenize(line)
    line.split(" ").map {|word| word.downcase }
  end
end
