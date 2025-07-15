# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative '../../implementations/prepare_deploy_process'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_process_deployed',
  tag: 'PrepareDeployProcess'
}

options = {}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::PrepareDeployProcess.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info("[PrepareDeployProcess] Error: #{e.message}")
  puts e.backtrace.join("\n")
end
