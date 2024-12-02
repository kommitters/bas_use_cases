# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module BirthdayConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/birthday/fetch_birthday_from_notion.rb', time: ['01:00:00'] },
    { path: '/birthday/format_birthday.rb', time: ['01:10:00'] },
    { path: '/birthday/garbage_collector.rb', time: ['13:00:00'] },
    { path: '/birthday/notify_birthday_in_discord.rb', time: ['13:10:00'] }
  ].freeze
end
