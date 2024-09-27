# frozen_string_literal: true
# 

require 'logger'
require_relative '../bots/review_website_availability'

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
    tag: "ReviewDomainRequest"
  },
  write_options: {
    connection:,
    db_table: "telegram_web_availability",
    tag: "ReviewWebsiteAvailability"
  }
}

begin
  bot = Bot::ReviewWebsiteAvailability.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
