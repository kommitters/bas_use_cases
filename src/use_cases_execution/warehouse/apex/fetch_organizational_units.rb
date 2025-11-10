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
  params: [false, 'FetchOrganizationalUnitsFromApex']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchOrganizationalUnitsFromApex'
}

process_options = {
  entity: 'organizational_unit',
  endpoint: 'organizational_units'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRecordsFromApexDatabase.new(process_options, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchOrganizationalUnitsFromApex',
                    message: 'Process completed successfully.',
                    context: { action: 'fetch', entity: 'Organizational Units' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchOrganizationalUnitsFromApex',
                     message: 'Error during fetching Organizational Units from Apex.',
                     context: { action: 'fetch', entity: 'Organizational Units' },
                     error: e.message
                   })
end
