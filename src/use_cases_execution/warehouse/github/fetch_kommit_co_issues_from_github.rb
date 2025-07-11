# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'
require_relative 'config'
require_relative '../../../implementations/fetch_releases_from_github'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchIssuesFromGithub']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchIssuesFromGithub'
}

options = {
  private_pem: Config::GITHUB_PRIVATE_PEM,
  app_id: Config::GITHUB_APP_ID,
  organization: Config::KOMMIT_CO_ORGANIZATION
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchReleasesFromGithub.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
