# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/deploy_process_in_operaton'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_process_deployed',
  tag: 'PrepareDeployProcess'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_process_deployed',
  tag: 'DeployProcess'
}

options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::DeployProcess.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info("[DeployProcess] Error: #{e.message}")
  puts e.backtrace.join("\n")
end
