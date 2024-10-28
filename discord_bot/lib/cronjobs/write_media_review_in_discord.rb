# frozen_string_literal: true

require 'logger'
require 'bas/bot/write_media_review_in_discord'

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
    db_table: 'review_images',
    tag: 'ReviewImage'
  },
  process_options: {
    secret_token: "Bot #{ENV.fetch('DISCORD_BOT_TOKEN')}"
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
