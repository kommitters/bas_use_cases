# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/update_new_networks_in_notion'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'FetchNewNetworksFromApollo'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'UpdateNewNetworksInNotion'
}

options = {
  secret: Config::NOTION_SECRET,
  database_id: Config::NETWORK_NOTION_DATABASE_ID
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::UpdateNewNetworksInNotion.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
