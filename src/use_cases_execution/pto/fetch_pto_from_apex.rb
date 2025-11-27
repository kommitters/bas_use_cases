# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_ptos_from_apex'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromApex',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchPtosFromApex']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromApex'
}

# Optional options passed to the Implementation
options = {
  apex_endpoint: 'taskman_pto'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  Implementation::FetchPtosFromApex.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
