# frozen_string_literal: true

require 'bas/bot/base'
require 'time'

module Implementation
  ##
  # This bot implements the logic to fetch records from an Operaton database's
  # endpoints, handles pagination, and stores it into the shared storage.
  #
  class FetchRecordsFromOperaton < Bas::Bot::Base
    FORMATTERS = {
      'process' => Utils::Warehouse::Operaton::Formatter::ProcessFormatter
    }.freeze

    PAGE_SIZE = 100

    ##
    # Main method that fetches all data, handling pagination.
    #
    def process
      initial_records = fetch_page
      return initial_records if initial_records.is_a?(Hash) && initial_records[:error]

      all_records = initial_records.concat(fetch_remaining_pages)
      entities = normalize_response(all_records)

      { success: { type: process_options[:entity], content: entities } }
    end

    ##
    # Writes the processed data to the warehouse.
    # This method remains unchanged and will handle batching correctly.
    #
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

    def fetch_remaining_pages
      all_records = []
      page_number = 1
      loop do
        page_records = fetch_page(page_number)
        break if page_records.empty?

        all_records.concat(page_records)
        page_number += 1
      end
      all_records
    end

    def fetch_page(page_number = 0)
      response = fetch_operaton_data(query_params: build_request_params(PAGE_SIZE * page_number))
      return error_response(response) unless response.success?

      response.parsed_response
    end

    def build_request_params(first_result = 0)
      {
        first_result: first_result,
        max_results: PAGE_SIZE
      }
    end

    ##
    # Executes a request to the Operaton API.
    #
    def fetch_operaton_data(query_params: {})
      Utils::Operaton::Request.execute(
        endpoint: process_options[:entity],
        query_params: query_params,
        method: process_options[:method],
        body: process_options[:body]
      )
    end

    ##
    # Uses the correct formatter to transform the raw data from Operaton.
    #
    def normalize_response(records)
      formatter_class = FORMATTERS[process_options[:entity]]
      raise "Formatter not found for entity: '#{process_options[:entity]}'" unless formatter_class

      records.map { |record| formatter_class.new(record).format }
    end

    ##
    # Builds the record that will be stored in the shared storage.
    #
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

    ##
    # Formats an error response.
    #
    def error_response(response)
      { error: { message: response.parsed_response, status_code: response.code } }
    end
  end
end
