# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/search_users_in_apollo'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'FetchNetworksEmaillessFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'SearchUsersInApollo'
}

options = {
  apollo_token: Config::APOLLO_TOKEN
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::SearchUsersInApollo.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
