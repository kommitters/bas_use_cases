# frozen_string_literal: true

require 'date'
require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../config'
require_relative '../helper'
require_relative '../../../implementations/fetch_records_from_operaton'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchActivitiesFromOperaton']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchActivitiesFromOperaton'
}

process_options = {
  entity: 'operaton_activity',
  endpoint: 'history/activity-instance',
  method: :post,
  body: {
    startedAfter: nil
  }
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  process_options[:body][:startedAfter] = Warehouse::Helper.get_last_execution_date(shared_storage)
  Implementation::FetchRecordsFromOperaton.new(process_options, shared_storage).execute

  Logger.new($stdout).info('Successfully fetched activities from Operaton.')
rescue StandardError => e
  Logger.new($stdout).error("Failed to fetch activities from Operaton: #{e.message}")
end
