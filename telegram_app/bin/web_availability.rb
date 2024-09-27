# frozen_string_literal: true

require_relative '../lib/web_availability'

# Telegram bot execution module
module WebAvailability
  class Error < StandardError; end

  connection = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: 'bas',
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }

  token = ENV.fetch('TELEGRAM_BOT_TOKEN')

  bot = Bots::WebAvailability.new(token, connection)

  bot.execute
end
