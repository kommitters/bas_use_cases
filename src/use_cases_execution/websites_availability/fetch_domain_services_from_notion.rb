# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/websites_availability/fetch_domain_services_from_notion'

# Configuration
params = {
  notion_database_id: ENV.fetch('WEBSITES_AVAILABILITY_NOTION_DATABASE_ID'),
  notion_secret: ENV.fetch('NOTION_SECRET'),
  table_name: 'web_availability',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Fetch::DomainServicesFromNotion.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
