# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'dotenv/load'

require_relative '../../implementations/notify_workspace_dm'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'missing_work_logs',
  tag: 'FetchPeopleWithMissingLogs'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'missing_work_logs',
  tag: 'NotifyWorkspaceDm'
}

credentials_json = ENV.fetch('SERVICE_ACCOUNT_CREDENTIALS_JSON') do
  raise 'SERVICE_ACCOUNT_CREDENTIALS_JSON environment variable is required'
end

begin
  JSON.parse(credentials_json)
rescue JSON::ParserError => e
  raise "Invalid JSON in SERVICE_ACCOUNT_CREDENTIALS_JSON: #{e.message}"
end

options = {
  credentials: credentials_json
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyWorkspaceDm.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
