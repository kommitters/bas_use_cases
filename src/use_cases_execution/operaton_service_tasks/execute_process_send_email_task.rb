# frozen_string_literal: true

require 'logger'
$LOAD_PATH.unshift(File.expand_path('../../../../bas/lib', __dir__))
require 'bas'
require_relative '../../implementations/process_send_email_task'
require_relative 'config'

# Configuration
options = {}

read_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskPolled'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskProcessed_SendEmail'
}

begin
  # The bot reads a 'Polled' task and writes a 'Processed' task.
  # The base bot logic handles marking the read record as 'processed'.
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::ProcessSendEmailTask.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end

