# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/warehouse_ingester'
require_relative 'config'

require 'pg'

array = PG::TextEncoder::Array.new.encode(
  %w[
    FetchReleasesFromGithubKommitters
    FetchPullRequestsFromGithubKommitters
    FetchIssuesFromGithubKommitters
    FetchReleasesFromGithubKommitCo
    FetchPullRequestsFromGithubKommitCo
    FetchIssuesFromGithubKommitCo
    FetchRepositoriesFromGithubKommitters
    FetchRepositoriesFromGithubKommitCo
    FetchRecordsFromWorkLogs
    FetchHiredPersonsFromNotionDatabase
    FetchGoogleDocumentsFromWorkspace
    FetchGoogleDocumentsActivityLogsFromWorkspace
    FetchCalendarEventsFromWebhook
    FetchKpisFromNotionDatabase
    FetchKeyResultsFromWebhook
    FetchKpisFromWebhook
    FetchOkrsFromApex
    FetchKrsFromApex
    FetchMilestonesFromApex
    FetchOrganizationalUnitsFromApex
    FetchProcessesFromApex
    FetchTasksFromApex
    FetchWeeklyScopesFromApex
    FetchWeeklyScopesTasksFromApex
    FetchProcessesFromOperaton
    FetchIncidentsFromOperaton
    FetchPeopleFromApex
  ]
)

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  where: 'archived=$1 AND tag=ANY($2) AND stage=$3 ORDER BY inserted_at ASC',
  params: [false, array, 'unprocessed']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'WarehouseSyncProcessed'
}

options = {
  db: Config::Database::WAREHOUSE_CONNECTION
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::WarehouseIngester.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
