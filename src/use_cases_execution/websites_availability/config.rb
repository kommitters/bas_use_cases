# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module WebsitesAvailabilityConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/websites_availability/fetch_domain_services_from_notion.rb', interval: 600_000 },
    { path: '/websites_availability/notify_domain_availability.rb', interval: 60_000 },
    { path: '/websites_availability/garbage_collector.rb', time: ['00:00:00'] },
    { path: '/websites_availability/review_domain_availability.rb', interval: 60_000 }
  ].freeze
end
