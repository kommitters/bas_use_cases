# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_records_from_apex_database'
require_relative '../config'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchWeeklyScopesTasksFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchWeeklyScopesTasksFromApex'
}

process_options = {
  entity: 'weekly_scope_task',
  endpoint: 'weekly_scopes_tasks'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  Logger.new($stdout).info('Successfully fetched weekly_scopes_tasks from APEX.')
rescue StandardError => e
  Logger.new($stdout).error("Failed to fetch weekly_scopes_tasks from APEX: #{e.message}")
end
