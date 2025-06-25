# frozen_string_literal: true

require 'date'
require 'google/apis/sheets_v4'
require 'googleauth'
require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FetchPtosFromGoogleSheets class serves as a bot implementation to read PTOs from a
  # Google Sheets document and format them into a human-readable description.
  #  <br>
  #  <b>Example</b>
  #
  #  write_options = {
  #    connection: Config::CONNECTION,
  #    db_table: 'pto',
  #    tag: 'FetchPtosFromGoogleSheetsForWorkspace'
  #  }
  #
  #  options = {
  #    spreadsheet_id: ENV.fetch('GOOGLE_SHEETS_SPREADSHEET_ID'),
  #    credentials_path: ENV.fetch('GOOGLE_SERVICE_ACCOUNT_JSON')
  #  }
  #
  #  begin
  #    shared_storage_reader = Bas::SharedStorage::Default.new
  #    shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #  Implementation::FetchPtosFromGoogleSheets.new(options, shared_storage_reader, shared_storage_writer).execute
  #  rescue StandardError => e
  #    Logger.new($stdout).info(e.message)
  #  end
  #
  class FetchPtosFromGoogleSheets < Bas::Bot::Base
    # Process function to execute the Google Sheets utility to fetch PTOs from the spreadsheet
    def process
      ptos = extract_and_humanize_ptos
      { success: { ptos: ptos } }
    end

    private

    def today
      @today ||= Date.today
    end

    def sheet_name
      'Sheet1'
    end

    def range
      "#{sheet_name}!A2:J"
    end

    def fetch_sheet_rows
      service = Google::Apis::SheetsV4::SheetsService.new
      service.authorization = sheet_auth
      response = service.get_spreadsheet_values(spreadsheet_id, range)
      response.values || []
    end

    def sheet_auth
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: File.open(credentials_path),
        scope: ['https://www.googleapis.com/auth/spreadsheets.readonly'],
        subject: 'info@podnation.co'
      )
    end

    def extract_and_humanize_ptos
      rows = fetch_sheet_rows
      rows.filter_map { |row| process_row(row) }
    end

    def process_row(row)
      return unless valid_row?(row)

      person, start_str, end_str, period, category = row.values_at(1, 3, 4, 5, 7)
      start_date = safe_parse_date(start_str)
      end_date = safe_parse_date(end_str)
      return unless start_date && end_date && (start_date..end_date).cover?(today)

      build_description(person, start_date, end_date, period, category)
    end

    def valid_row?(row)
      person, start_str, end_str, _, _, status = extract_fields(row)
      [person, start_str, end_str].none?(&:nil?) && status.to_s.downcase != 'inactive'
    end

    def extract_fields(row)
      [
        row[1], # Person (B)
        row[3], # StartDateTime (D)
        row[4], # EndDateTime (E)
        row[5], # Day (F)
        row[7], # Category (H)
        row[9]  # Status (J)
      ]
    end

    def safe_parse_date(str)
      Date.strptime(str.strip, '%m/%d/%Y')
    rescue ArgumentError
      nil
    end

    def build_description(name, start_date, end_date, period, category)
      return_date = compute_return_date(end_date.next_day)
      day_phrase = day_period_phrase(start_date, end_date, period)
      reason = category_text(category)

      "#{name} will not be working #{day_phrase} due to #{reason}. And returns the #{return_date}."
    end

    def compute_return_date(date)
      date += 1 while weekend?(date)
      date.strftime('%A %B %-d of %Y')
    end

    def weekend?(date)
      date.saturday? || date.sunday?
    end

    def day_period_phrase(start_date, end_date, period)
      return half_day_phrase(start_date, period) if period.to_s.downcase.include?('half day')

      same_day = start_date == end_date
      same_day ? "on #{format_date(start_date)}" : "between #{format_date(start_date)} and #{format_date(end_date)}"
    end

    def half_day_phrase(date, period)
      time = period.to_s.downcase.include?('am') ? 'in the morning' : 'in the afternoon'
      "on #{format_date(date)} #{time}"
    end

    def format_date(date)
      date.strftime('%B %-d, %Y')
    end

    def category_text(category)
      cleaned = category.to_s.strip
      cleaned.empty? ? 'PTO' : cleaned
    end

    def spreadsheet_id
      process_options[:spreadsheet_id]
    end

    def credentials_path
      process_options[:credentials_path]
    end
  end
end
