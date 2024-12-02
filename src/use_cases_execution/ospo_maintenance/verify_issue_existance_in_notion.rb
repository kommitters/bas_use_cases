# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../implementations/verify_issue_existance_in_notion'
require_relative 'config'

# Configuration
{
  connection: OspoMaintenance::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest'
}

write_options = {
  connection: OspoMaintenance::CONNECTION,
  db_table: 'github_issues',
  tag: 'VerifyIssueExistanceInNotio'
}

options = {
  database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::VerifyIssueExistanceInNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
