# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../implementations/prepare_billing_start_instance'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_instances',
  tag: 'PrepareStartInstance'
}

options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  process_key: 'billing_process',
  operaton_api_user: ENV.fetch('OPERATON_API_USER'),
  operaton_password: ENV.fetch('OPERATON_PASSWORD')
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::PrepareBillingStartInstance.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
  puts e.backtrace.join("\n")
end
