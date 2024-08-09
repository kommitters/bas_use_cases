# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/digital_ocean_bill_alert/fetch_billing_from_digital_ocean'

# Configuration
params = {
  digital_ocean_secret: ENV.fetch('DIGITAL_OCEAN_SECRET'),
  table_name: 'do_billing',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Fetch::BillingFromDigitalOcean.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
