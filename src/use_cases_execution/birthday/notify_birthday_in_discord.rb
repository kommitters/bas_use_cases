# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/birthday/notify_birthday_in_discord'

# Configuration
params = {
  discord_webhook: ENV.fetch('BIRTHDAY_DISCORD_WEBHOOK'),
  discord_bot_name: ENV.fetch('DISCORD_BOT_NAME'),
  table_name: ENV.fetch('BIRTHDAY_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Notify::BirthdayInDiscord.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
