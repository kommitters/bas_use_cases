# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_hired_persons_from_notion'
require_relative 'config'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchHiredPersonsFromNotionDatabase']
}

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
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchHiredPersonsFromNotionDatabase.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
