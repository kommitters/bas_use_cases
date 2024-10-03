# frozen_string_literal: true

require_relative '../lib/discord_images'

# Discord bot execution module
module DiscordImages
  class Error < StandardError; end

  connection = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: 'bas',
    table_name: 'review_images',
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }

  token = ENV.fetch('DISCORD_BOT_TOKEN')

  bot = Bots::DiscordImages.new(token, connection)

  bot.execute
end
