files = Dir.glob( File.join("unit", "*.rb") )
files.each{ |file|
  puts "\n#{Array.new(80,'-').join}\nRunning tests in #{file}..."
  system("ruby2.0 #{file}")
}
