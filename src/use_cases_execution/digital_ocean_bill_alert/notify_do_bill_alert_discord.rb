# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/digital_ocean_bill_alert/notify_do_bill_alert_discord'

# Configuration
params = {
  discord_webhook: ENV.fetch('DIGITAL_OCEAN_DISCORD_WEBHOOK'),
  discord_bot_name: ENV.fetch('DISCORD_BOT_NAME'),
  table_name: 'do_billing',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Notify::DoBollAlertDiscord.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
