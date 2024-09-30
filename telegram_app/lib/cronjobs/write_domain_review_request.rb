# frozen_string_literal: true

require 'logger'
require 'bas/bot/write_domain_review_requests'

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
    db_table: 'telegram_web_availability',
    tag: 'FetchWebsiteReviewRequest'
  },
  process_options: {
    connection:,
    db_table: 'telegram_web_availability',
    tag: 'ReviewDomainRequest'
  },
  write_options: {
    connection:,
    db_table: 'telegram_web_availability',
    tag: 'WriteDomainReviewRequests'
  }
}

begin
  bot = Bot::WriteDomainReviewRequests.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
