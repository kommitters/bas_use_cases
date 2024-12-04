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
        @actual_time = Time.new

        @schedules.each do |script|
          execute_interval(script) if interval?(script)
          execute_day(script) if day?(script) && time?(script)
          execute_time(script) if time?(script) && !day?(script)
        end
        sleep 0.01
      end
    end

    private

    def execute_interval(script)
      ms_time = time_in_milliseconds(@actual_time)
      return unless ms_time - @last_executions[script[:path]] >= script[:interval]

      execute(script)
      @last_executions[script[:path]] = ms_time
    end

    def execute_day(script)
      time = current_time(@actual_time)
      day = current_day(@actual_time)
      return unless script[:day].include?(day) && script[:time].include?(time)

      execute(script)
    end

    def execute_time(script)
      time = current_time(@actual_time)
      execute(script) if script[:time].include?(time)
    end

    def interval?(script)
      script[:interval]
    end

    def time?(script)
      script[:time]
    end

    def day?(script)
      script[:day]
    end

    def time_in_milliseconds(time)
      time.to_f * 1000
    end

    def current_time(actual_time)
      actual_time.strftime('%H:%M:%S')
    end

    def current_day(actual_time)
      actual_time.strftime('%A')
    end

    def execute(script)
      puts "Executing #{script[:path]} at #{current_time(@actual_time)}"
      system("ruby #{File.join(@path, script[:path])}")
    end
  end
end
