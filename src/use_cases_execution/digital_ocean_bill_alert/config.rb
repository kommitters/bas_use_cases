# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module DigitalOceanBillAlertConfig
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb', interval: 300_000 },
    { path: '/digital_ocean_bill_alert/format_do_bill_alert.rb', interval: 300_000 },
    { path: '/digital_ocean_bill_alert/garbage_collector.rb', interval: 300_000 },
    { path: '/digital_ocean_bill_alert/notify_do_bill_alert_discord.rb', interval: 300_000 }
  ].freeze
end
