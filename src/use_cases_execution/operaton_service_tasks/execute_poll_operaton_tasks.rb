# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/poll_operaton_tasks'
require_relative 'config'

module Bas
  module Utils
    Postgres = ::Utils::Postgres
  end
end

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'operaton_tasks',
  tag: 'OperatonTaskPolled'
}

options = {
  operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  worker_id: ENV.fetch('OPERATON_POLLER_WORKER_ID', "operaton_poller_#{Time.now.to_i}"),
  # We can add a list of topics to poll in the future from an ENV var:
  # topics: ENV.fetch('OPERATON_TOPICS', 'send_email,variables').split(',')
  topics: 'send_email,variables'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::PollOperatonTasks.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
