# frozen_string_literal: true

require 'logger'
require_relative '../bots/notify_telegram'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: 'bas',
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

options = {
  read_options: {
    connection:,
    db_table: 'observed_websites_availability',
    tag: 'WebsiteAvailability'
  },
  process_options: {
    connection:,
    token: ENV.fetch('TELEGRAM_BOT_TOKEN')
  },
  write_options: {
    connection:,
    db_table: 'observed_websites_availability',
    tag: 'NotifyTelegram'
  }
}

begin
  bot = Implementation::NotifyTelegram.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info("(NotifyTelegram) #{e.message}")
end
