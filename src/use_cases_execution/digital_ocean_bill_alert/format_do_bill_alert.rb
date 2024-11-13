# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/format_do_bill_alert'

# Configuration
options = {
  read_options: {
    connection: {
      host: ENV.fetch('DB_HOST'),
      port: ENV.fetch('DB_PORT'),
      dbname: ENV.fetch('POSTGRES_DB'),
      user: ENV.fetch('POSTGRES_USER'),
      password: ENV.fetch('POSTGRES_PASSWORD')
    },
    db_table: "do_billing",
    tag: "FetchBillingFromDigitalOcean"
  },
  process_options: {
    threshold: ENV.fetch('DIGITAL_OCEAN_THRESHOLD').to_f
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
    tag: "FormatDoBillAlert"
  }
}

# Process bot
begin
  bot = Bot::FormatDoBillAlert.new(options)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
