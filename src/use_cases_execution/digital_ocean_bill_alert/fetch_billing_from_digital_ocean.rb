# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_billing_from_digital_ocean'

# Configuration
options = {
  process_options: {
    secret: ENV.fetch('DIGITAL_OCEAN_SECRET')
  },
  write_options: {
    connection: {
      host: ENV.fetch('DB_HOST'),
      port: ENV.fetch('DB_PORT'),
      dbname: ENV.fetch('POSTGRES_DB'),
      user: ENV.fetch('POSTGRES_USER'),
      password: ENV.fetch('POSTGRES_PASSWORD')
    },
    db_table: "do_billing",
    tag: "FetchBillingFromDigitalOcean"
  }
}

# Process bot
begin
  bot = Bot::FetchBillingFromDigitalOcean.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
