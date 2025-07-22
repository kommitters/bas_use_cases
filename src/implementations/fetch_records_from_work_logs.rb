# frozen_string_literal: true

require 'bas/bot/base'
require 'date'
require_relative '../utils/warehouse/work_logs/request'
require_relative '../utils/warehouse/work_logs/work_log_formatter'

module Implementation
  ##
  # Implementation::FetchRecordsFromWorkLogs
  #
  # This class implements a bot that fetches records from the WorkLogs API
  # within a given time range and prepares them to be saved into the data warehouse.
  #
  # <b>Usage Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchRecordsFromWorkLogs']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchRecordsFromWorkLogs'
  #   }
  #
  #   options = {
  #     work_logs_url: Config::WORK_LOGS_URL,
  #     secret: Config::WORK_LOGS_API_SECRET,
  #     entity: 'work_log'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::FetchRecordsFromWorkLogs
  #     .new(options, shared_storage)
  #     .execute
  #
  class FetchRecordsFromWorkLogs < Bas::Bot::Base
    RECORDS_PER_PAGE = 100
    PAGE_SIZE = 100

    def process
      start_date = (read_response.inserted_at || Date.new(2023, 7, 10)).to_s
      logs = fetch_all_logs(start_date)
      normalized_content = normalize_response(logs)

      { success: { type: process_options[:entity], content: normalized_content } }
    rescue StandardError => e
      error_response(e)
    end

    def write
      return @shared_storage_writer.write(process_response) if process_response[:error]

      content = process_response.dig(:success, :content) || []
      paged_entities = content.each_slice(PAGE_SIZE).to_a

      paged_entities.each_with_index do |page, idx|
        record = build_record(
          content: page, page_index: idx + 1,
          total_pages: paged_entities.size, total_records: content.size
        )
        @shared_storage_writer.write(record)
      end
    end

    private

    def fetch_all_logs(start_date)
      all_logs = []
      page = 1
      loop do
        response = fetch_page(start_date, page)
        handle_failed_response(response) unless response.success?

        all_logs.concat(new_log = response.parsed_response['logs'])
        break if new_log.size < RECORDS_PER_PAGE

        page += 1
      end
      all_logs
    end

    def fetch_page(start_date, page)
      params = { start_date: start_date, end_date: Date.today.to_s, page: page }
      Utils::WorkLogs::Request.execute(
        token: process_options[:secret],
        base_url: process_options[:work_logs_url],
        params: params
      )
    end

    def normalize_response(records)
      records.map { |record| Utils::Warehouse::WorkLogs::WorkLogFormatter.new(record).format }
    end

    def handle_failed_response(response)
      raise "Error fetching data: #{response.code} - #{response.message}"
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: process_options[:entity],
          content: content,
          page_index: page_index,
          total_pages: total_pages,
          total_records: total_records
        }
      }
    end

    def error_response(response)
      { error: { message: response.message } }
    end
  end
end
