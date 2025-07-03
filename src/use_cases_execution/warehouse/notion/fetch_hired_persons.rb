# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../implementations/fetch_hired_persons_from_notion'
require_relative 'config'

write_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchHiredPersonsFromNotionDatabase'
}

options = {
  db: Config::WAREHOUSE_CONNECTION,
  database_id: Config::HIRED_PERSONS_NOTION_DATABASE_ID,
  secret: Config::NOTION_SECRET,
  entity: 'person'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchHiredPersonsFromNotionDatabase.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
