# frozen_string_literal: true

require 'logger'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative '../../implementations/fetch_github_issues_for_notion_sync'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync',
  tag: 'FetchGithubIssues'
}

options = {
  repo_identifier: Config::REPO_IDENTIFIER,
  github_api_token: Config::GITHUB_TOKEN
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchGithubIssuesForNotionSync.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
