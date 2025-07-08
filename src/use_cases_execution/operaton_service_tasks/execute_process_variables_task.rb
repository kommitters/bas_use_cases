# frozen_string_literal: true

require 'logger'

require 'bas/shared_storage/base'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/process_variables_task'
require_relative 'config'

# Configuration
options = {}

# This bot reads a 'Polled' task.
read_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskPolled'
}

# It writes a 'Processed_Variables' task after executing its logic.
write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskProcessed_Variables'
}

begin
  # The bot reads a 'Polled' task and writes a 'Processed_Variables' task.
  # The base bot logic handles marking the read record as 'processed'.
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::ProcessVariablesTask.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
