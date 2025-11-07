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
  params: [false, 'FetchMilestonesFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchMilestonesFromApex'
}

process_options = {
  entity: 'apex_milestone',
  endpoint: 'milestones'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchMilestonesFromApex',
                    message: 'Process completed successfully.',
                    context: { action: 'fetch', entity: 'Milestones' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchMilestonesFromApex',
                     message: 'Error during fetching Milestones from Apex.',
                     context: { action: 'fetch', entity: 'Milestones' },
                     error: e.message
                   })
end
