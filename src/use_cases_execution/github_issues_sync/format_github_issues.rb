# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_github_issues_for_apex'
require_relative 'config'

read_options = {
  connection: Config::CONNECTION,
  db_table:   'github_issues_apex',
  where:      "stage='unprocessed' AND tag=$1 ORDER BY inserted_at DESC",
  params:     ['GithubIssueRequest']
}

write_options = {
  connection: Config::CONNECTION,
  db_table:   'github_issues_apex',
  tag:        'FormatGithubIssuesApex'
}

options = {
  close_connection_after_process: false,
  avoid_empty_data: true,
  default_status:   Config::DEFAULT_STATUS,
  default_deadline: Config::DEFAULT_DEADLINE
}

logger = Logger.new($stdout)

begin
  shared_storage = Bas::SharedStorage::Postgres.new(
    read_options:  read_options,
    write_options: write_options
  )

  object = Implementation::FormatGithubIssuesForApex.new(options, shared_storage)
  object.execute

  shared_storage.close_connections

rescue StandardError => e
  shared_storage&.close_connections
  logger.error(e.message)
end
