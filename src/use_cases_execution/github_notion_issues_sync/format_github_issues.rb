# frozen_string_literal: true

require 'logger'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/format_github_issues_for_notion'
require_relative 'config'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  where: "stage='unprocessed' AND tag=$1 ORDER BY inserted_at DESC",
  params: ['GithubIssueRequest']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'FormatGithubIssues'
}

options = {
  close_connection_after_process: false,
  avoid_empty_data: true,
  notion_property: Config::NOTION_PROPERTY
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  # Format GitHub issues for Notion and store them in PostgreSQL
  (1..Config::MAX_RECORDS).each do
    object = Implementation::FormatGithubIssuesForNotion.new(options, shared_storage)
    object.execute
    break if object.process_response.key?(:error)
  end

  shared_storage.close_connections
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
