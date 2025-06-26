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
  #    credentials: ENV.fetch('SERVICE_ACCOUNT_CREDENTIALS_JSON'),
  #    sheet_name: 'Sheet1',
  #    range: 'A2:J',
  #    column_mapping: {
  #      person: 1, # Column B
  #      start_date: 3, # Column D
  #      end_date: 4, # Column E
  #      period: 5, # Column F
  #      category: 7, # Column H
  #      status: 9 # Column J
  #    }
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
    def process
      ptos = extract_and_humanize_ptos
      { success: { ptos: ptos } }
    end

    private

    def today
      @today ||= Date.today
    end

    def sheet_name
      process_options[:sheet_name] || "'PTO Summary #{today.year}'"
    end

    def range
      "#{sheet_name}!#{process_options[:range] || 'A2:J'}"
    end

    def fetch_sheet_rows
      service = Google::Apis::SheetsV4::SheetsService.new
      service.authorization = sheet_auth
      begin
        response = service.get_spreadsheet_values(spreadsheet_id, range)
        response.values || []
      rescue Google::Apis::Error => e
        raise "Google Sheets API error: #{e.message}"
      end
    end

    def sheet_auth
      Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(credentials_json),
        scope: ['https://www.googleapis.com/auth/spreadsheets.readonly']
      )
    end

    def credentials_json
      process_options[:credentials] || raise('Missing :credentials in process_options')
    end

    def extract_and_humanize_ptos
      fetch_sheet_rows.filter_map { |row| process_row(row) }
    end

    def process_row(row)
      return unless valid_row?(row)

      person, start_str, end_str, period, category = extract_fields(row).values_at(
        :person, :start_date, :end_date, :period, :category
      )

      start_date = safe_parse_date(start_str)
      end_date = safe_parse_date(end_str)
      return unless start_date && end_date && (start_date..end_date).cover?(today)

      build_description(person, start_date, end_date, period, category)
    end

    def valid_row?(row)
      fields = extract_fields(row)
      [fields[:person], fields[:start_date], fields[:end_date]].none?(&:nil?) &&
        fields[:status].to_s.downcase != 'inactive'
    end

    def extract_fields(row)
      map = process_options[:column_mapping]
      {
        person: row[map[:person]],
        start_date: row[map[:start_date]],
        end_date: row[map[:end_date]],
        period: row[map[:period]],
        category: row[map[:category]],
        status: row[map[:status]]
      }
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
  end
end
