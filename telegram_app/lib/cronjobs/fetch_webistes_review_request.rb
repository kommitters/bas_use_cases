# frozen_string_literal: true

require 'logger'
require_relative '../bots/fetch_website_review_request'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: 'bas',
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

options = {
  process_options: {
    connection:,
    db_table: 'websites',
    tag: 'ReviewTextRequest'
  },
  write_options: {
    connection:,
    db_table: 'telegram_web_availability',
    tag: 'FetchWebsiteReviewRequest'
  }
}

begin
  bot = Bot::FetchWebsiteReviewRequest.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
