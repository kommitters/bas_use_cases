# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_people_with_missing_logs'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'missing_work_logs',
  tag: 'FetchPeopleWithMissingLogs'
}

options = {
  secret: Config::WORK_LOGS_API_SECRET,
  work_logs_url: "#{Config::WORK_LOGS_URL}/api/v1/users/last_work_logs",
  days: 7,
  workspace_webhook: Config::MISSING_WORK_LOGS_WORKSPACE_WEBHOOK
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchPeopleWithMissingLogs.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
