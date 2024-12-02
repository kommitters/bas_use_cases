# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module PtoConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/pto/fetch_pto_from_notion.rb', time: ['13:10:00'] },
    { path: '/pto/humanize_pto.rb', time: ['13:20:00'] },
    { path: '/pto/garbage_collector.rb', time: ['13:30:00'] },
    { path: '/pto/notify_pto_in_discord.rb', time: ['13:40:00'] }
  ].freeze
end
