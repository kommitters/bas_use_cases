# frozen_string_literal: true

require 'logger'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/format_github_issues_for_notion'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync',
  tag: 'FetchGithubIssues'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync',
  tag: 'FormatGithubIssues'
}

options = {}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  # Format GitHub issues for Notion and store them in PostgreSQL
  Implementation::FormatGithubIssuesForNotion.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
