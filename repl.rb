require "./forthr"

interpreter = ForthR::Interpreter.new
print '> '

ARGF.each_line do |line|
  interpreter << line
  result = interpreter.read
  puts result unless result.empty?
  print '> '
end
