# frozen_string_literal: true

require 'logger'
require 'bas/bot/write_media_review_in_discord'

connection = {
  discord_bot_token: ENV.fetch('DISCORD_BOT_TOKEN'),
  table_name: 'review_images',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

options = {
  read_options: {
    connection:,
    db_table: 'review_images',
    tag: 'ReviewText'
  },
  process_options: {
    secret_token: "Bot #{ENV.fetch('DISCORD_BOT_TOKEN')}",
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
