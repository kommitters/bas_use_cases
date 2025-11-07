# frozen_string_literal: true

require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_records_from_apex_database'
require_relative '../../../../log/bas_logger'
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

  BAS_LOGGER.info({
                    invoker: 'FetchWeeklyScopesTasksFromApex',
                    message: 'Process completed successfully.',
                    context: { action: 'fetch', entity: 'Weekly Scopes Tasks' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchWeeklyScopesTasksFromApex',
                     message: 'Error during fetching Weekly Scopes Tasks from Apex.',
                     context: { action: 'fetch', entity: 'Weekly Scopes Tasks' },
                     error: e.message
                   })
end
