# frozen_string_literal: true
# 

require 'logger'
require_relative '../bots/notify_telegram'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: "bas",
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

options = {
  read_options: {
    connection:,
    db_table: "telegram_web_availability",
    tag: "ReviewWebsiteAvailability"
  },
  process_options: {
    token: ENV.fetch('TELEGRAM_BOT_TOKEN')
  },
  write_options: {
    connection:,
    db_table: "telegram_web_availability",
    tag: "NotifyTelegram"
  }
}

begin
  bot = Bot::NotifyTelegram.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
