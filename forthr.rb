module ForthR
  class Interpreter < Struct.new(:words, :stack, :out, :code)
    def initialize
      primitives = {
        ".s"     => Proc.new { out << "#{stack.join(' ')} "                         },
        "."      => Proc.new { out << "#{stack.pop} "                               },
        "+"      => Proc.new { stack << stack.pop + stack.pop                       },
        "-"      => Proc.new { stack << -stack.pop + stack.pop                      },
        "*"      => Proc.new { stack << stack.pop * stack.pop                       },
        "/"      => Proc.new { y, x = stack.pop, stack.pop; stack << x / y          },
        "negate" => Proc.new { stack << -stack.pop                                  },
        "mod"    => Proc.new { y, x = stack.pop, stack.pop; stack << x % y          },
        "/mod"   => Proc.new { y, x = stack.pop, stack.pop; stack << x % y << x / y },
        "dup"    => Proc.new { stack << stack.last                                  },
        "drop"   => Proc.new { stack.pop                                            },
        "swap"   => Proc.new { y, x = stack.pop, stack.pop; stack << y << x         },
        "nip"    => Proc.new { y, x = stack.pop, stack.pop; stack << y              },
        "tuck"   => Proc.new { y, x = stack.pop, stack.pop; stack << y << x << y    },
        "("      => Proc.new { code.consume_until ")"                               },
        "\\"     => Proc.new { code.clear                                           },
        ":"      => Proc.new { define_word code, words                              },
        "see"    => Proc.new { out << words[code.shift].see(words)                  },
        "false"  => Proc.new { stack << 0                                           },
        "true"   => Proc.new { stack << -1                                          },
        "bye"    => Proc.new { exit                                                 },
      }

      self.words = Words.new primitives.merge(primitives) {|name, lambda| PrimitiveWord.new(name, &lambda) }
      self.stack = []
      self.out = ""
      self.code = Code.new
    end

    def define_word(code, words)
      name = code.shift.downcase
      words[name] = CompositeWord.new(name, code.consume_until(";"), words)
    end

    def <<(line)
      self.code = Code.new line
      call code.shift until code.empty?
    end

    def call(word)
      words[word.downcase].call self
    end

    def read
      result, self.out = self.out, ""
      result
    end

    def size; stack.size; end
  end

  class Code < Array
    def initialize(line = "")
      super line.split(" ")
    end

    def consume_until(terminator)
      result = []
      result << shift until result.last == terminator
      result[0..-2]
    end
  end

  class PrimitiveWord < Proc
    attr_reader :block, :name

    def initialize(name, &block)
      @name = name
      @block = block
    end

    def expand
      name
    end

    def to_s
      "<primitive>: #{block.source_location.join(":")}"
    end

    def see(*)
      to_s
    end
  end

  class CompositeWord < Struct.new(:name, :code, :expanded_code)
    def initialize(name, code, words)
      expanded_code = code.map {|word| words[word].expand }.flatten
      super name, code, expanded_code
    end

    def call(state)
      expanded_code.each do |word|
        state.words[word].call state
      end
    end

    def expand
      expanded_code
    end

    def to_s
      code.join(" ") + " ; "
    end

    def see(words)
      words[name].to_s
    end
  end

  class NumericWord < Struct.new(:number)
    def initialize(string)
      self.number = Integer(string)
    end

    def call(state)
      state.stack << number
    end

    def expand
      number.to_s
    end

    def see(*)
      ":#{number.to_s}: <Undefined word>"
    end
  end

  class UndefinedWord < Struct.new(:name)
    def call(state)
      raise see
    end

    def expand
      raise see
    end

    def see(*)
      ":#{name}: <Undefined word>"
    end
  end

  class Words < Struct.new(:dictionary)
    include Enumerable

    def [](key)
      return NumericWord.new(key) if is_numeric? key
      dictionary.fetch(key) { UndefinedWord.new(key) }
    end

    def []=(key, value)
      dictionary[key] = value
    end

    def each(&block)
      dictionary.each &block
    end

    private

    def is_numeric?(value)
      value.match /\A[+-]?\d+?(\.\d+)?\Z/
    end
  end
end
