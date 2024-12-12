# frozen_string_literal: true

module Whatsapp
  ##
  # This module contains the schedules for the scripts that will be executed by the orchestrator.
  # Each schedule is a hash with the following
  # keys:
  # path: The path to the script that will
  # time: The time when the script will be executed
  # day: The day when the script will be executed
  module Schedules
    def self.schedules
      constants.reduce([]) { |schedules, schedule| schedules + const_get(schedule) }
    end

    SCHEDULES = [
      { path: '/command_processor.rb', interval: 1_000 },
      { path: '/fetch_websites_review_request.rb', interval: 60_000 },
      { path: '/review_website_availability.rb', interval: 60_000 },
      { path: '/notify_whatsapp.rb', interval: 5_000 }
    ].freeze
  end
end
