# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_pto_from_notion'
require_relative 'config'

# Configuration

options = {
  database_id: ENV.fetch('PTO_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

write_options = {
  connection: PtoConfig::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromNotion'
}

puts write_options, options

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchPtosFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
