# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_pto_from_drive'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchPtosFromGoogleSheetsForWorkspace'
}

options = {
  spreadsheet_id: ENV.fetch('GOOGLE_SHEETS_SPREADSHEET_ID'),
  credentials: ENV.fetch('SERVICE_ACCOUNT_CREDENTIALS_JSON'),
  sheet_name: 'Sheet1',
  range: 'A2:J',
  column_mapping: {
    person: 1, # Column B
    start_date: 3, # Column D
    end_date: 4, # Column E
    period: 5, # Column F
    category: 7, # Column H
    status: 9 # Column J
  }
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::FetchPtosFromGoogleSheets.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
