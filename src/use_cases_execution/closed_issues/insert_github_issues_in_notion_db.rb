# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/update_notion_db_with_github_issues'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest',
  where: 'tag=$1 ORDER BY inserted_at DESC LIMIT 1',
  params: ['GithubIssueRequest']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest',
}

options = {
  notion_database_id: Config::NOTION_CLOSED_ISSUES_DATABASE_ID,
  notion_secret: Config::NOTION_SECRET,
  tag: 'GithubIssueRequest'
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::UpdateNotionDBWithGithubIssues.new(options, shared_storage).execute

rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
