# frozen_string_literal: true

require 'bas/shared_storage/postgres'

require_relative '../config'
require_relative '../../../../log/bas_logger'
require_relative '../../../implementations/fetch_records_from_apex_database'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchPeopleFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchPeopleFromApex'
}

process_options = {
  entity: 'people',
  endpoint: 'people'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchPeopleFromApex',
                    message: 'Successfully fetched people from APEX.',
                    context: { action: 'fetch', entity: 'People' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchPeopleFromApex',
                     message: 'Error during fetching people from APEX',
                     context: { action: 'fetch', entity: 'People' },
                     error: e.message
                   })
end
