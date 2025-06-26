# frozen_string_literal: true

require 'date'
require 'google/apis/sheets_v4'
require 'googleauth'
require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FetchNextWeekPtosFromGoogleSheets class serves as a bot implementation
  # to read PTOs for the next week from a Google Sheets document and format them into
  # a human-readable description.
  #  <br>
  #  <b>Example</b>
  #
  #  write_options = {
  #    connection: Config::CONNECTION,
  #    db_table: 'pto',
  #    tag: 'FetchNextWeekPtosFromGoogleSheetsForWorkspace'
  #  }
  #
  #  options = {
  #    spreadsheet_id: ENV.fetch('GOOGLE_SHEETS_SPREADSHEET_ID'),
  #    credentials: ENV.fetch('SERVICE_ACCOUNT_CREDENTIALS_JSON')
  #    sheet_name: 'Sheet1',
  #    range: 'A2:J',
  #  }
  #
  #  begin
  #    shared_storage_reader = Bas::SharedStorage::Default.new
  #    shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #    Implementation::FetchNextWeekPtosFromGoogleSheets.new
  # (options, shared_storage_reader, shared_storage_writer).execute
  #  rescue StandardError => e
  #    Logger.new($stdout).info(e.message)
  #  end
  class FetchNextWeekPtosFromGoogleSheets < Bas::Bot::Base
    # Process function to execute the Google Sheets utility to fetch PTOs for the next week
    def process
      { success: { ptos: fetch_rows.filter_map { |row| format_pto(row) } } }
    end

    private

    def fetch_rows
      Google::Apis::SheetsV4::SheetsService
        .new
        .tap { |svc| svc.authorization = sheet_credentials }
        .get_spreadsheet_values(spreadsheet_id, "#{process_options[:sheet_name]}!#{process_options[:range] || 'A2:J'}")
        .values || []
    end

    def sheet_credentials
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials_json),
        scope: ['https://www.googleapis.com/auth/spreadsheets.readonly']
      )
    end

    def credentials_json
      process_options[:credentials] || raise('Missing :credentials in process_options')
    end

    def format_pto(row)
      return unless valid_row?(row)

      person, start_str, end_str, period, category = row.values_at(1, 3, 4, 5, 7)
      start_date = safe_date(start_str)
      end_date = safe_date(end_str)

      return unless dates_valid?(start_date, end_date)
      return unless date_in_range?(start_date, end_date)

      build_pto_message(person, start_date, end_date, period, category)
    end

    def valid_row?(row)
      person, start_str, end_str, status = row.values_at(1, 3, 4, 9)
      [person, start_str, end_str].none?(&:nil?) && status.to_s.downcase != 'inactive'
    end

    def safe_date(str)
      Date.strptime(str.strip, '%m/%d/%Y')
    rescue StandardError
      nil
    end

    def dates_valid?(start_date, end_date)
      start_date && end_date
    end

    def date_in_range?(start_date, end_date)
      range = next_week_range
      range.cover?(start_date) ||
        range.cover?(end_date) ||
        (start_date < range.begin && end_date > range.end)
    end

    def build_pto_message(name, start_date, end_date, period, category)
      phrase = date_phrase(start_date, end_date, period)
      reason = category.to_s.strip.empty? ? 'PTO' : category.strip
      return_date = format_return(next_working_day(end_date.next_day))

      "#{name} will not be working #{phrase} due to #{reason}. And returns the #{return_date}."
    end

    def next_working_day(date)
      date += 1 while date.saturday? || date.sunday?
      date
    end

    def date_phrase(start_date, end_date, period)
      return half_day_phrase(start_date, period) if period.to_s.downcase.include?('half day')

      if start_date == end_date
        "on #{format_date(start_date)}"
      else
        "between #{format_date(start_date)} and #{format_date(end_date)}"
      end
    end

    def half_day_phrase(date, period)
      time = period.to_s.downcase.include?('am') ? 'in the morning' : 'in the afternoon'
      "on #{format_date(date)} #{time}"
    end

    def format_date(date)
      date.strftime('%B %-d, %Y')
    end

    def format_return(date)
      date.strftime('%A %B %-d of %Y')
    end

    def next_week_range
      monday = today + ((1 - today.wday) % 7)
      monday..(monday + 6)
    end

    def today
      @today ||= Date.today
    end

    def spreadsheet_id
      process_options[:spreadsheet_id]
    end
  end
end
