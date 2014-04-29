require 'method_source'

class ForthR
  Stack = []

  def initialize
    @out = ""
    primitives = {
      ".s"     => lambda { @out << "#{Stack.join(' ')} " },
      "."      => lambda { @out << "#{Stack.pop} " },
      "+"      => lambda { Stack << Stack.pop + Stack.pop },
      "-"      => lambda { Stack << -Stack.pop + Stack.pop },
      "*"      => lambda { Stack << Stack.pop * Stack.pop },
      "/"      => lambda { y, x = Stack.pop, Stack.pop; Stack << x / y },
      "negate" => lambda { Stack << -Stack.pop },
      "mod"    => lambda { y, x = Stack.pop, Stack.pop; Stack << x % y },
      "/mod"   => lambda { y, x = Stack.pop, Stack.pop; Stack << x % y << x / y },
      "dup"    => lambda { Stack << Stack.last},
      "drop"   => lambda { Stack.pop },
      "swap"   => lambda { y, x = Stack.pop, Stack.pop; Stack << y << x },
      "nip"    => lambda { y, x = Stack.pop, Stack.pop; Stack << y },
      "tuck"   => lambda { y, x = Stack.pop, Stack.pop; Stack << y << x << y },
      "("      => lambda { consume_until ")" },
      "\\"     => lambda { @code.clear },

      ":"      => lambda do
        defined_word = @code.shift.downcase
        code = consume_until ";"
        expanded_code = code.map {|w| compile w }.flatten
        definition = CompositeWord.new(expanded_code, method(:process))
        @words[defined_word] = definition
      end,

      "see"     => lambda { @out << decompile(@code.shift) },
      "bye"     => lambda { exit }
    }

    @words = Words.new primitives.each {|name,lambda| primitives[name] = Word.new(name, &lambda) }
  end

  def <<(line)
    @code = line.split(" ")
    process @code.shift until @code.empty?
  end

  def process(word)
    word = word.downcase
    @words[word].call
  end

  def compile(word)
    return @words[word].map {|w| compile w }.flatten if @words[word].class == CompositeWord
    word
  end

  def decompile(word)
    return @words[word].to_s if @words[word]
    "<Undefined word: #{word}>"
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

  def size; Stack.size; end

  class Word < Proc
    attr_reader :block

    def initialize(name, &block)
      @name = name
      @block = block
      super &block
    end

    def to_s
      "<primitive>: #{block.source_location.join(":")}"
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

    def to_s
      join(" ") + " ; "
    end

    def call
      expanded_code.each {|w| process.call w }
    end
  end

  class UndefinedWord < Struct.new(:name)
    def to_s
      ":#{name}: <Undefined word>"
    end

    def call
      begin
        Stack << Integer(name)
      rescue
        raise to_s
      end
    end
  end

  class Words < Struct.new(:dictionary)
    include Enumerable

    def [](key)
      dictionary.fetch(key) { UndefinedWord.new(key) }
    end

    def []=(key,value)
      dictionary[key] = value
    end

    def each(&block)
      dictionary.each &block
    end
  end
end
