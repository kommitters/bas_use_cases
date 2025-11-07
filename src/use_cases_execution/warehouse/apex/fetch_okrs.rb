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
  params: [false, 'FetchOkrsFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchOkrsFromApex'
}

process_options = {
  entity: 'okr',
  endpoint: 'okrs'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchOkrsFromApex',
                    message: 'Process completed successfully.',
                    context: { action: 'fetch', entity: 'OKRs' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchOkrsFromApex',
                     message: 'Error during fetching OKRs from Apex.',
                     context: { action: 'fetch', entity: 'OKRs' },
                     error: e.message
                   })
end
