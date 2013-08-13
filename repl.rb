require "./forthr"

interpreter = ForthR.new
print '> '

ARGF.each_line do |line|
  exit if line.downcase == "bye\n"
  interpreter << line
  result = interpreter.read
  puts result unless result.empty?
  print '> '
end