# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/start_process_instance_in_operaton_process'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_instances',
  tag: 'PrepareStartInstance'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_instances',
  tag: 'StartProcessInstance'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::StartProcessInstance.new({}, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info("[StartProcessInstance] Error: #{e.message}")
  puts e.backtrace.join("\n")
end
