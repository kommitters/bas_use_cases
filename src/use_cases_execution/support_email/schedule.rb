require_relative './config'

# Path to the folder where the bot is located
path = 'C:/Users/Ghosty/Documents/kommit/Projects/bas_use_cases/src/use_cases_execution/support_email'

#Take the schedule from the Config module
schedule = Config::SCHEDULE

last_executions = Hash.new(0.0)

loop do 
  current_time = Time.now.to_f * 1000

  schedule.each do |script|
    if current_time - last_executions[script[:path]] >= script[:interval]
      system("ruby #{path}#{script[:path]}")
      last_executions[script[:path]] = current_time
    end
  end

  sleep 0.01
end