# frozen_string_literal: true

require_relative '../lib/discord_images'

# Discord bot execution module
module DiscordImages
  class Error < StandardError; end

  connection = {
    host: 'bas_db',
    port: '5432',
    dbname: 'bas',
    table_name: 'review_images',
    user: 'postgres',
    password: 'postgres'
  }

  token = 'MTI4NDE1MzY1NTc1NDM2MzA0MQ.GdL5Fk.tU9kMLBbk4E0v3XVms0H90SBnlbC5mSljhAcQk'
  client_id = '1285982248813990028'

  bdi = Bots::DiscordImages.new(token, client_id, connection)
  bdi.execute
  bdi.bot.run
end
