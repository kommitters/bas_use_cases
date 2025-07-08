# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../implementations/poll_operaton_tasks'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskPolled'
}

options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  worker_id: ENV.fetch('OPERATON_POLLER_WORKER_ID', "operaton_poller_#{Time.now.to_i}"),
  topics: 'send_email,variables'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::PollOperatonTasks.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info("[Poller] Error: #{e.message}")
  puts e.backtrace.join("\n")
end
