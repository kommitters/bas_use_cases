# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/review_images/write_image_review_in_discord'

# Configuration
params = {
  discord_bot_token: ENV.fetch('DISCORD_BOT_TOKEN'),
  table_name: 'review_images',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Write::ImageReviewInDiscord.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
