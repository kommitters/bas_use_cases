# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_networks_emailless_from_notion'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'FetchNetworksEmaillessFromNotion'
}

options = {
  database_id: Config::NETWORK_NOTION_DATABASE_ID,
  secret: Config::NOTION_SECRET
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchNetworksEmaillessFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
