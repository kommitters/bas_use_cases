# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module WipLimitConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/wip_limit/fetch_domains_wip_count.rb', time: ['12:20:00', '14:20:00', '18:20:00', '20:20:00'] },
    { path: '/wip_limit/fetch_domains_wip_limit.rb', time: ['12:30:00', '14:30:00', '18:30:00', '20:30:00'] },
    { path: '/wip_limit/compare_wip_limit_count.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'] },
    { path: '/wip_limit/garbage_collector.rb', time: ['21:10:00'] },
    { path: '/wip_limit/format_wip_limit_exceeded.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'] },
    { path: '/wip_limit/notify_domains_wip_limit_exceeded.rb', time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'] }
  ].freeze
end
