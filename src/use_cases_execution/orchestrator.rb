# frozen_string_literal: true

require_relative './schedules'

module ScheduleOrchestrator
  # Orchestrator class is responsible for running scheduled scripts based on the defined schedules.
  # It will check the current time and execute the scripts that match the time and day.
  # It will also execute scripts based on the defined interval.
  # The schedules are defined in the UseCasesExecution::Schedules module.
  class Orchestrator
    def initialize(base_path = __dir__, schedules = UseCasesExecution::Schedules.schedules)
      @last_executions = Hash.new(0.0)
      @path = base_path
      @schedules = schedules
    end

    def run
      loop do
        current_time = current_time_in_milliseconds
        time = current_time_formatted
        day = current_day_formatted

        process_schedules(current_time, time, day)

        sleep 0.01
      end
    end

    private

    def interval?(script)
      script[:interval]
    end

    def time?(script)
      script[:time]
    end

    def day?(script)
      script[:day]
    end

    def current_time_in_milliseconds
      Time.new.to_f * 1000
    end

    def current_time_formatted
      Time.new.strftime('%H:%M:%S')
    end

    def current_day_formatted
      Time.new.strftime('%A')
    end

    def process_schedules(current_time, time, day)
      @schedules.each do |script|
        execute(script, time) if should_execute_script?(current_time, time, day, script)
      end
    end

    def should_execute_script?(current_time, time, day, script)
      (interval?(script) &&
        should_execute_interval?(current_time, script)) ||
        (time?(script) &&
         day?(script) &&
        should_execute_time?(time, script) &&
        should_execute_day?(day, script)) ||
        (time?(script) && should_execute_time?(time, script))
    end

    def update_last_execution(current_time, script)
      @last_executions[script[:path]] = current_time if interval?(script)
    end

    def should_execute_interval?(current_time, script)
      is_interval_script = current_time - @last_executions[script[:path]] >= script[:interval]
      update_last_execution(current_time, script) if is_interval_script
      is_interval_script
    end

    def should_execute_time?(time, script)
      script[:time].include?(time)
    end

    def should_execute_day?(day, script)
      script[:day].include?(day)
    end

    def execute(script, time)
      puts "Executing #{script[:path]} at #{time}"
      system("ruby #{File.join(@path, script[:path])}")
    end
  end
end

orchestrator = ScheduleOrchestrator::Orchestrator.new
orchestrator.run
