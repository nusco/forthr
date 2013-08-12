class ForthR
  def initialize
    @stack = []
    @output = []
    @words = {
      ".s" => lambda { @output << @stack.join(" ") },
      "." => lambda { @stack.pop }, 
    }
  end

  def <<(line)
    tokenize(line).each do |command|
      if @words[command]
        @words[command].call
      else
        @stack << command
      end
    end
  end

  def output
    @output.join
  end

  def size
    @stack.size
  end

  def tokenize(line)
    line.split(" ")
  end
end
