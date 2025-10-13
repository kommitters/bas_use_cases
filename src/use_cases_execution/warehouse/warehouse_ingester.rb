# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/warehouse_ingester'
require_relative 'config'

require 'pg'

array = PG::TextEncoder::Array.new.encode(
  %w[
    FetchDomainsFromNotionDatabase
    FetchDocumentsFromNotionDatabase
    FetchWeeklyScopesFromNotionDatabase
    FetchKeyResultsFromNotionDatabase
    FetchProjectsFromNotionDatabase
    FetchActivitiesFromNotionDatabase
    FetchPersonsFromNotionDatabase
    FetchWorkItemsFromNotionDatabase
    FetchMilestonesFromNotionDatabase
    FetchRecordsFromWorkLogs
    FetchHiredPersonsFromNotionDatabase
    FetchReleasesFromGithub
    FetchIssuesFromGithub
    FetchPullRequestsFromGithub
    FetchGoogleDocumentsFromWorkspace
    FetchGoogleDocumentsActivityLogsFromWorkspace
    FetchCalendarEventsFromWebhook
    FetchKpisFromNotionDatabase
    FetchKeyResultsFromWebhook
    FetchKpisFromWebhook
    FetchActivitiesFromApex
    FetchDomainsFromApex
    FetchPersonsFromApex
    FetchProjectsFromApex
    FetchWorkItemsFromApex
    FetchProcessesFromOperaton
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
