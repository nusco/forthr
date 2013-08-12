class ForthR
  def initialize
    @stack = []
    @output = []
    @words = {
      ".s"      => lambda { @output << @stack.join(" ") },
      "."       => lambda { @output << @stack.pop }, 
      "+"       => lambda { @stack << @stack.pop + @stack.pop }, 
      "-"       => lambda { @stack << -@stack.pop + @stack.pop }, 
      "*"       => lambda { @stack << @stack.pop * @stack.pop }, 
      "/"       => lambda { div = @stack.pop; @stack << @stack.pop / div}, 
      "negate"  => lambda { @stack << -@stack.pop }, 
      "dup"     => lambda { @stack << @stack.last}, 
    }
  end

  def <<(line)
    tokenize(line).each do |command|
      if @words[command]
        @words[command].call
      else
        begin
          @stack << Integer(command)
        rescue
          raise "Unknown word: #{command}"
        end
      end
    end
  end

  def output
    @output.join("\n")
  end

  def size
    @stack.size
  end

  def tokenize(line)
    line.split(" ").map {|word| word.downcase }
  end
end
