# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_records_from_notion_database'
require_relative 'config'

# Configuration

write_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchRecordsFromNotionDatabase'
}

options = {
  database_id: Config::WORK_ITEMS_NOTION_DATABASE_ID,
  secret: Config::NOTION_SECRET,
  entity: 'work_item'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchRecordsFromNotionDatabase.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
