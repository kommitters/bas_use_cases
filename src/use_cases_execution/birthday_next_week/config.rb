# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module BirthdayNextWeekConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/birthday_next_week/fetch_next_week_birthday_from_notion.rb', time: ['01:00:00'] },
    { path: '/birthday_next_week/format_next_week_birthday.rb', time: ['01:10:00'] },
    { path: '/birthday_next_week/garbage_collector.rb', time: ['13:00:00'] },
    { path: '/birthday_next_week/notify_next_week_birthday_in_discord.rb', time: ['13:10:00'] }
  ].freeze
end
