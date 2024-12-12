# frozen_string_literal: true

require_relative 'schedules'

module Whatsapp
  module Execution
    # Orchestrator class is responsible for running scheduled scripts based on the defined schedules.
    # It will check the current time and execute the scripts that match the time and day.
    # It will also execute scripts based on the defined interval.
    # The schedules are defined in the UseCasesExecution::Schedules module.
    class Orchestrator
      def initialize
        @last_executions = Hash.new(0.0)
        @schedules = Whatsapp::Schedules.schedules
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
        return unless time_in_milliseconds - @last_executions[script[:path]] >= script[:interval]

        execute(script)

        @last_executions[script[:path]] = time_in_milliseconds
      end

      def execute_day(script)
        return unless script[:day].include?(current_day) && script[:time].include?(current_time)

        execute(script) unless @last_executions[script[:path]].eql?(current_time)

        @last_executions[script[:path]] = current_time
      end

      def execute_time(script)
        execute(script) if script[:time].include?(current_time) && !@last_executions[script[:path]].eql?(current_time)

        @last_executions[script[:path]] = current_time
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

      def time_in_milliseconds
        @actual_time.to_f * 1000
      end

      def current_time
        @actual_time.strftime('%H:%M')
      end

      def current_day
        @actual_time.strftime('%A')
      end

      def execute(script)
        puts "Executing #{script[:path]} at #{current_time}"

        system("ruby #{File.join(__dir__, script[:path])}")
      end
    end
  end
end
