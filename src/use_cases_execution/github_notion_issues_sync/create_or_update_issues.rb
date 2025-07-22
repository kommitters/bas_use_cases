# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/create_or_update_issue'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  where: "stage='unprocessed' AND tag=$1 ORDER BY inserted_at DESC",
  params: ['FormatGithubIssues']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'CreateOrUpdateIssueInNotion'
}

options = {
  avoid_empty_data: true,
  notion_property: Config::NOTION_PROPERTY,
  secret: ENV.fetch('NOTION_SECRET'),
  database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  (1..Config::MAX_RECORDS).each do
    object = Implementation::CreateOrUpdateIssue.new(options, shared_storage)
    object.execute
    break if object.process_response.key?(:error)
  end

  shared_storage.close_connections
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
