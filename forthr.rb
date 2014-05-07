module ForthR
  class Interpreter < Struct.new(:words, :stack, :memory, :last_alloc, :out, :code)
    FALSE = 0
    TRUE = -1

    def initialize
      primitives = {
        ".s"       => Proc.new { out << "#{stack.join(' ')} "                                  },
        "."        => Proc.new { out << "#{stack.pop} "                                        },
        "+"        => Proc.new { stack << stack.pop + stack.pop                                },
        "-"        => Proc.new { stack << -stack.pop + stack.pop                               },
        "*"        => Proc.new { stack << stack.pop * stack.pop                                },
        "/"        => Proc.new { y, x = stack.pop, stack.pop; stack << x / y                   },
        "negate"   => Proc.new { stack << -stack.pop                                           },
        "mod"      => Proc.new { y, x = stack.pop, stack.pop; stack << x % y                   },
        "/mod"     => Proc.new { y, x = stack.pop, stack.pop; stack << x % y << x / y          },
        "dup"      => Proc.new { stack << stack.last                                           },
        "drop"     => Proc.new { stack.pop                                                     },
        "swap"     => Proc.new { y, x = stack.pop, stack.pop; stack << y << x                  },
        "nip"      => Proc.new { y, x = stack.pop, stack.pop; stack << y                       },
        "tuck"     => Proc.new { y, x = stack.pop, stack.pop; stack << y << x << y             },
        "("        => Proc.new { code.consume_until ")"                                        },
        "\\"       => Proc.new { code.clear                                                    },
        ":"        => Proc.new { define_word code, words                                       },
        "variable" => Proc.new { define_variable(code, words)                                  },
        "!"        => Proc.new { memory[stack.pop] = stack.pop                                 },
        "@"        => Proc.new { stack << memory[stack.pop]                                    },
        "see"      => Proc.new { out << words[code.shift].see(words)                           },
        "false"    => Proc.new { stack << FALSE                                                },
        "true"     => Proc.new { stack << TRUE                                                 },
        "="        => Proc.new { stack << (stack.pop == stack.pop ? TRUE : FALSE)              },
        "?do"      => Proc.new { doloop stack.pop, stack.pop, code                             },
        "bye"      => Proc.new { exit                                                          },
      }

      self.words = Words.new primitives.merge(primitives) {|name, lambda| PrimitiveWord.new(name, &lambda) }
      self.stack = []
      self.memory = [0] * 65536
      self.last_alloc = 0
      self.out = ""
      self.code = Code.new
    end

    def define_word(code, words)
      name = code.shift
      words[name] = CompositeWord.new(name, code.consume_until(";"), words)
    end

    def define_variable(code, words)
      variable_name = code.shift
      words[variable_name] = VariableWord.new(variable_name, self.last_alloc)
      self.last_alloc += 1
    end

    def doloop(from, to, code)
      words = code.consume_until "loop"
      (from + 1).upto(to) { execute words.clone }
    end

    def <<(line)
      self.code = Code.new line.downcase
      execute code
    end

    def execute(words)
      call words.shift until words.empty?
    end

    def call(word)
      words[word].call self
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

  class VariableWord < Struct.new(:name, :address)
    def call(state)
      state.stack << address
    end

    def see(*)
      "Variable #{name}"
    end

    def expand(*)
      name.to_s
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
