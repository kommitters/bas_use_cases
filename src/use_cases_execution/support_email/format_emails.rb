# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/support_email/format_emails'

# Configuration
params = {
  table_name: 'support_emails',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Format::EmailsFromImap.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
