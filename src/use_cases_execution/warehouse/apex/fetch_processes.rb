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
  params: [false, 'FetchProcessesFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchProcessesFromApex'
}

process_options = {
  entity: 'process',
  endpoint: 'processes'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchProcessesFromApex',
                    message: 'Process completed successfully.',
                    context: { action: 'fetch', entity: 'Processes' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchProcessesFromApex',
                     message: 'Error during fetching Processes from Apex.',
                     context: { action: 'fetch', entity: 'Processes' },
                     error: e.message
                   })
end
