# frozen_string_literal: true

require 'logger'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative '../../implementations/fetch_github_issues_with_specific_params'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest'
}

options = {  
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  # Run the GitHub issues query and store them in PostgreSQL
  Implementation::FetchGithubIssues.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
