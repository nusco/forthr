require "./forthr"

interpreter = ForthR::Interpreter.new
print '> '

ARGF.each_line do |line|
  begin
    interpreter << line
    result = interpreter.read
    puts result unless result.empty?
  rescue Exception => e
    puts e
  end
  print '> '
end
