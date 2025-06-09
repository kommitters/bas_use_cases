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

options = {
  credentials: ENV['SERVICE_ACCOUNT_CREDENTIALS_JSON']
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyWorkspaceDm.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
