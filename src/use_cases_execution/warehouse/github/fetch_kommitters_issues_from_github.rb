# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative '../config'
require_relative '../../../implementations/fetch_issues_from_github'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchIssuesFromGithub']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchIssuesFromGithub'
}

github_config = Config::Github.kommiters

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchIssuesFromGithub.new(github_config, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
