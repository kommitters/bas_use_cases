# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/websites_availability/notify_domain_availability'

# Configuration
params = {
  discord_webhook: ENV.fetch('WEBSITES_AVAILABILITY_DISCORD_WEBHOOK'),
  discord_bot_name: ENV.fetch('DISCORD_BOT_NAME'),
  table_name: 'web_availability',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Notify::DomainAvailability.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
