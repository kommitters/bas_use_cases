# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/websites_availability/review_domain_availability'

# Configuration
params = {
  table_name: 'web_availability',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Review::DomainAvailability.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
