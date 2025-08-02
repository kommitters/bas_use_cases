# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_records_from_work_logs'
require_relative '../config'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchRecordsFromWorkLogs']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchRecordsFromWorkLogs'
}

options = {
  work_logs_url: Config::Worklogs::URL,
  secret: Config::Worklogs::API_SECRET,
  entity: 'work_log'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromWorkLogs.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
