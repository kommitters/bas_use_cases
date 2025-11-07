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
  params: [false, 'FetchWeeklyScopesFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchWeeklyScopesFromApex'
}

process_options = {
  entity: 'weekly_scope',
  endpoint: 'weekly_scopes'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchWeeklyScopesFromApex',
                    message: 'Process completed successfully.',
                    context: { action: 'fetch', entity: 'Weekly Scopes' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchWeeklyScopesFromApex',
                     message: 'Error during fetching Weekly Scopes from Apex.',
                     context: { action: 'fetch', entity: 'Weekly Scopes' },
                     error: e.message
                   })
end
