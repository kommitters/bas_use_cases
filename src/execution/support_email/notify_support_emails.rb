# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/support_email/notify_support_emails'

# Configuration
params = {
  discord_webhook: ENV.fetch('SUPPORT_EMAIL_DISCORD_WEBHOOK'),
  discord_bot_name: ENV.fetch('DISCORD_BOT_NAME'),
  table_name: ENV.fetch('SUPPORT_EMAIL_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('DB_NAME'),
  db_user: ENV.fetch('DB_USER'),
  db_password: ENV.fetch('DB_PASSWORD')
}

# Process bot
begin
  bot = Notify::SupportEmails.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
