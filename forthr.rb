class ForthR
  def initialize
    @out = ""
    @stack = []
    primitives = {
      ".s"     => lambda {|words, stack| @out << "#{stack.join(' ')} " },
      "."      => lambda {|words, stack| @out << "#{stack.pop} " },
      "+"      => lambda {|words, stack| stack << stack.pop + stack.pop },
      "-"      => lambda {|words, stack| stack << -stack.pop + stack.pop },
      "*"      => lambda {|words, stack| stack << stack.pop * stack.pop },
      "/"      => lambda {|words, stack| y, x = stack.pop, stack.pop; stack << x / y },
      "negate" => lambda {|words, stack| stack << -stack.pop },
      "mod"    => lambda {|words, stack| y, x = stack.pop, stack.pop; stack << x % y },
      "/mod"   => lambda {|words, stack| y, x = stack.pop, stack.pop; stack << x % y << x / y },
      "dup"    => lambda {|words, stack| stack << stack.last},
      "drop"   => lambda {|words, stack| stack.pop },
      "swap"   => lambda {|words, stack| y, x = stack.pop, stack.pop; stack << y << x },
      "nip"    => lambda {|words, stack| y, x = stack.pop, stack.pop; stack << y },
      "tuck"   => lambda {|words, stack| y, x = stack.pop, stack.pop; stack << y << x << y },
      "("      => lambda {|words, stack| consume_until ")" },
      "\\"     => lambda {|words, stack| @code.clear },
      ":"      => lambda {|words, stack| define_word @code, words },
      "see"    => lambda {|words, stack| @out << @words[@code.shift].show(@words) },
      "bye"    => lambda {|words ,stack| exit }
    }

    @words = Words.new primitives.each {|name,lambda| primitives[name] = Word.new(name, &lambda) }
  end

  def <<(line)
    @code = line.split(" ")
    call @code.shift until @code.empty?
  end

  def call(word)
    @words[word.downcase].call @words, @stack
  end

  def define_word(code,words)
    name = code.shift.downcase
    words[name] = CompositeWord.new name, consume_until(";")
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

  def size; @stack.size; end

  class Word < Proc
    attr_reader :block, :name

    def initialize(name, &block)
      @name = name
      @block = block
      super &block
    end

    def expand(*)
      name
    end

    def to_s
      "<primitive>: #{block.source_location.join(":")}"
    end

    def show(*)
      to_s
    end
  end

  class CompositeWord < Struct.new(:name, :code)
    include Enumerable

    def each(&block)
      code.each &block
    end

    def join(*args)
      code.join(*args)
    end

    def expand(words)
      code.map {|word| words[word].expand(words) }.flatten
    end

    def to_s
      join(" ") + " ; "
    end

    def show(words)
      words[name].to_s
    end

    def call(words, stack)
      expand(words).each do |word|
        words[word].call words, stack
      end
    end
  end

  class UndefinedWord < Struct.new(:name)
    def to_s
      ":#{name}: <Undefined word>"
    end

    def expand(*)
      name
    end

    def call(words, stack)
      begin
        stack << Integer(name)
      rescue
        raise to_s
      end
    end

    def show(*)
      to_s
    end
  end

  class Words < Struct.new(:dictionary)
    include Enumerable

    def [](key)
      begin
        return Integer(name)
      rescue
        dictionary.fetch(key) { UndefinedWord.new(key) }
      end
    end

    def []=(key,value)
      dictionary[key] = value
    end

    def each(&block)
      dictionary.each &block
    end
  end
end
