# frozen_string_literal: true

require_relative './birthday/config'
require_relative './birthday_next_week/config'
require_relative './digital_ocean_bill_alert/config'
require_relative './ospo_maintenance/config'
require_relative './pto/config'
require_relative './pto_next_week/config'
require_relative './support_email/config'
require_relative './websites_availability/config'
require_relative './wip_limit/config'

module OrchestratorWithSchedules
  # This module is responsible for loading all the schedules from the use cases
  # and storing them in a constant
  # Also, the orchestrator will use this constant to execute the scripts
  # based on the schedule
  # The schedules are stored in the SCHEDULES constant

  module Paths
    SCHEDULES = []

    def self.load_schedules
      Object.constants.each do |const_name|
        const = Object.const_get(const_name)
        next unless const.is_a?(Module) && const.constants.include?(:SCHEDULE) && !SCHEDULES.any? do |job|
          job[:module] == const_name
        end

        SCHEDULES.concat(const::SCHEDULE.map { |job| job.merge(module: const_name) })
      end
    end
  end

  Paths.load_schedules

  class Orchestrator
    def initialize(base_path = __dir__, schedules = Paths::SCHEDULES)
      @last_executions = Hash.new(0.0)
      @path = base_path
      @schedules = schedules
    end

    def run
      loop do
        actual_time = Time.new
        current_time = actual_time.to_f * 1000
        time = actual_time.strftime('%H:%M:%S')
        day = actual_time.strftime('%A')

        @schedules.each do |script|
          if script[:interval] && (current_time - @last_executions[script[:path]] >= script[:interval])
            puts "Executing #{script[:path]} at #{time}"
            system("ruby #{File.join(@path, script[:path])}")
            @last_executions[script[:path]] = current_time
          elsif (script[:time] && script[:day]) && (script[:time].include?(time) && script[:day].include?(day))
            puts "Executing #{script[:path]} at #{time}"
            system("ruby #{File.join(@path, script[:path])}")
          elsif script[:time] && script[:time].include?(time)
            puts "Executing #{script[:path]} at #{time}"
            system("ruby #{File.join(@path, script[:path])}")
          end
        end

        sleep 0.01
      end
    end
  end
end

orchestrator = OrchestratorWithSchedules::Orchestrator.new
orchestrator.run
