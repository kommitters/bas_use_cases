# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../implementations/complete_operaton_task'
require_relative 'config'

# Configuration
options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  worker_id: ENV.fetch('OPERATON_POLLER_WORKER_ID', "operaton_completer_#{Time.now.to_i}")
}

# This bot reads records created by ANY worker.
read_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  # We use a LIKE query to find any processed task, regardless of the topic.
  where: 'archived=$1 AND tag LIKE $2 AND stage=$3 ORDER BY inserted_at ASC',
  params: [false, 'OperatonTaskProcessed_%', 'unprocessed']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskCompleted'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::CompleteOperatonTask.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
