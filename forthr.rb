class ForthR
  def initialize
    @stack = []
  end

  def <<(line)
    tokenize(line).each do |command|
      @stack << command
    end
  end

  def size
    @stack.size
  end

  def tokenize(line)
    commands = line.split(/\s*/).compact
    commands.delete("")
    commands
  end
end
