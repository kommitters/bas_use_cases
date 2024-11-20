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
    db_table: 'observed_websites',
    tag: 'ReviewTextRequest'
  },
  write_options: {
    connection:,
    db_table: 'observed_websites_availability',
    tag: 'FetchWebsiteReviewRequest'
  }
}

begin
  bot = Implementation::FetchWebsiteReviewRequest.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info("(FetchWebsiteReviewRequest) #{e.message}")
end
