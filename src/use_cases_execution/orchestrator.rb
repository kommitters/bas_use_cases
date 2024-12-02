# frozen_string_literal: true

require_relative 'paths'

# actual path
path = __dir__

# Take the schedule from the path module
schedules = Paths::SCHEDULES

last_executions = Hash.new(0.0)

loop do
  actual_time = Time.new
  current_time = actual_time.to_f * 1000
  time = actual_time.strftime('%H:%M:%S')
  day = actual_time.strftime('%A')

  schedules.each do |script|
    if script[:interval] && (current_time - last_executions[script[:path]] >= script[:interval])
      puts "Executing #{script[:path]} at #{time}"
      system("ruby #{File.join(path, script[:path])}")
      last_executions[script[:path]] = current_time
    elsif (script[:time] && script[:day]) && (script[:time].include?(time) && script[:day].include?(day))
      puts "Executing #{script[:path]} at #{time}"
      system("ruby #{File.join(path, script[:path])}")
    elsif script[:time] && script[:time].include?(time)
      puts "Executing #{script[:path]} at #{time}"
      system("ruby #{File.join(path, script[:path])}")
    end
  end

  sleep 0.01
end
