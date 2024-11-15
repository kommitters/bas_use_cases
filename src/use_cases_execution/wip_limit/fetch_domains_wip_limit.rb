# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_domains_wip_limit'
require_relative 'config'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'FetchDomainsWipCountsFromNotion'
}

options = {
  database_id: ENV.fetch('WIP_COUNT_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Bot::FetchDomainsWipCountsFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
