# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_next_week_pto_from_drive'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchNextWeekPtosFromGoogleSheetsForWorkspace'
}

options = {
  spreadsheet_id: ENV.fetch('GOOGLE_SHEETS_SPREADSHEET_ID'),
  credentials: ENV.fetch('SERVICE_ACCOUNT_CREDENTIALS_JSON'),
  sheet_name: 'Sheet1',
  range: 'A2:J'
}

begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchNextWeekPtosFromGoogleSheets.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
