# frozen_string_literal: true

require 'logger'
require 'bas/bot/write_media_review_in_discord'
puts "IN WMFD"

connection = {
  host: 'bas_db',
  port: '5432',
  dbname: 'bas',
  user: 'postgres',
  password: 'postgres'
}

options = {
  read_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewText'
  },
  process_options: {
    secret_token: "Bot MTI4NDE1MzY1NTc1NDM2MzA0MQ.GdL5Fk.tU9kMLBbk4E0v3XVms0H90SBnlbC5mSljhAcQk",
  },
  write_options: {
    connection:,
    db_table: 'review_images',
    tag: 'WriteMediaReviewInDiscord'
  }
}

begin
  bot = Bot::WriteMediaReviewInDiscord.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
