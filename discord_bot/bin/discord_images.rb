# frozen_string_literal: true

require_relative '../lib/discord_images'

# Discord bot execution module
module DiscordImages
  class Error < StandardError; end

  connection = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: 'bas',
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }

  token = ENV.fetch('DISCORD_BOT_TOKEN')
  client_id = ENV.fetch('DISCORD_CLIENT_ID')

  bdi = Bots::DiscordImages.new(token, client_id, connection)
  bdi.execute
  bdi.bot.run
end
