# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/digital_ocean_bill_alert/notify_do_bill_alert_email.rb'

# Configuration
params = {
  refresh_token: ENV.fetch('DIGITAL_OCEAN_REFRESH_TOKEN'),
  client_id: ENV.fetch('DIGITAL_OCEAN_CLIENT_ID'),
  client_secret: ENV.fetch('DIGITAL_OCEAN_CLIENT_SECRET'),
  user_email: ENV.fetch('DIGITAL_OCEAN_USER_EMAIL'),
  recipient_email: ENV.fetch('DIGITAL_OCEAN_RECIPIENT_EMAIL'),
  table_name: ENV.fetch('DO_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Notify::DoBillAlertEmail.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
