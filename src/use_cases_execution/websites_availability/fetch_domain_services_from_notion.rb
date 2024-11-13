# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_domain_services_from_notion'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: "web_availability",
  tag: "FetchDomainServicesFromNotion"
}

options = {
  database_id: ENV.fetch('WEBSITES_AVAILABILITY_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage_reader = SharedStorage::Default.new
  shared_storage_writer = SharedStorage::Postgres.new({ write_options: })
  
  Bot::FetchDomainServicesFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
