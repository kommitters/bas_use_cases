# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/update_networks'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'SearchUsersInApollo'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'UpdateNetworks'
}

options = {
  secret: Config::NOTION_SECRET
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::UpdateNetworks.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
