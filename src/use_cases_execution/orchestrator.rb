require 'parallel'

base_path = File.expand_path('src')

#obtain all the files in the src folder that are schedulers
schedulers = Dir.glob("#{base_path}/**/schedule.rb")

#run each scheduler in parallel
Parallel.each(schedulers, in_threads: schedulers.length) do |scheduler|
  puts "Running #{scheduler}"
  system("ruby #{scheduler}")
end
