# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_records_from_notion_database'
require_relative '../config'

# Configuration
read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchKpisFromNotionDatabase']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchKpisFromNotionDatabase'
}

options = {
  database_id: Config::Notion::KPIS_DATABASE_ID,
  secret: Config::Notion::SECRET,
  entity: 'kpi'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromNotionDatabase.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
