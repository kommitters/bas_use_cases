# frozen_string_literal: true

require 'logger'

require 'bas/shared_storage/base'
require 'bas/shared_storage/postgres'
require 'date'
require_relative '../../implementations/start_process_instance_in_operaton_process'
require_relative 'config'

# Configuration
options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  operaton_api_user: ENV.fetch('OPERATON_API_USER'),
  operaton_password: ENV.fetch('OPERATON_PASSWORD')
}

read_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_instances',
  tag: 'PrepareStartInstance'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_instances',
  tag: 'OperatonInstanceCreated'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::StartProcessInstance.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
