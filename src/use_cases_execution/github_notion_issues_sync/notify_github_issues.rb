# frozen_string_literal: true

require 'logger'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/notify_github_issues_to_notion'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync',
  tag: 'FormatGithubIssues'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync',
  tag: 'NotifyGithubIssues'
}

options = {
  notion_database_id: Config::NOTION_DATABASE_ID,
  notion_secret: Config::NOTION_SECRET
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  # Send formatted GitHub issues to Notion
  Implementation::NotifyGithubIssuesToNotion.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
