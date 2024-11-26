# frozen_string_literal: true

=begin
  INSTRUCTIONS:

  This file is used to store the configuration of the birthday use case.
  It contains the connection information to the database and the schedule of the bot.
  The schedule configuration has two fields: path and interval.
  The path is the path to the script that will be executed
  The interval is the time in milliseconds that the script will be executed
=end

require 'dotenv/load'

module Config
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: "/fetch_domains_wip_count.rb", interval: 1000 },
    { path: "/fetch_domains_wip_limit.rb", interval: 1000},
    { path: "/compare_wip_limit_count.rb", interval: 1000},
    { path: "/garbage_collector.rb", interval: 1000},
    { path: "/format_wip_limit_exceeded.rb", interval: 1000},
    { path: "/notify_domains_wip_limit_exceeded.rb", interval: 1000}
  ].freeze
end
