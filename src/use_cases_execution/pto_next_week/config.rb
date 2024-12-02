# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module PtoNextWeekConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/pto_next_week/fetch_next_week_pto_from_notion.rb', time: ['12:40:00'], day: ['Thursday'] },
    { path: '/pto_next_week/humanize_next_week_pto.rb', time: ['12:50:00'], day: ['Thursday'] },
    { path: '/pto_next_week/notify_next_week_pto_in_discord.rb', time: ['13:00:00'], day: ['Thursday'] },
    { path: '/pto_next_week/garbage_collector.rb', time: ['13:10:00'], day: ['Thursday'] }
  ].freeze
end
