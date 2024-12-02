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

# Global module to handle the paths of the scripts
module Paths
  SCHEDULES = []

  def self.load_schedules
    # iterate over all the modules and extract the configuration
    Object.constants.each do |const_name|
      const = Object.const_get(const_name)
      if const.is_a?(Module) && const.constants.include?(:SCHEDULE)
        SCHEDULES.concat(const::SCHEDULE.map { |job| job.merge(module: const_name) })
      end
    end
  end
end

Paths.load_schedules
module Paths
  SCHEDULES = []

  def self.load_schedules
    # iterate over all the modules and extract the configuration
    Object.constants.each do |const_name|
      const = Object.const_get(const_name)
      if const.is_a?(Module) && const.constants.include?(:SCHEDULE)
        SCHEDULES.concat(const::SCHEDULE.map { |job| job.merge(module: const_name) })
      end
    end
  end
end

Paths.load_schedules
