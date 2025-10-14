# frozen_string_literal: true

require 'bas/bot/base'
require 'time'
require_relative '../utils/warehouse/operaton/process_formatter'
require_relative '../utils/warehouse/operaton/request'

module Implementation
  ##
  # This bot implements the logic to fetch records from an Operaton database's
  # endpoints, handles pagination, and saves them into the shared storage.
  #
  class FetchRecordsFromOperaton < Bas::Bot::Base
    FORMATTERS = {
      'process' => Utils::Warehouse::Operaton::Formatter::ProcessFormatter
    }.freeze

    PAGE_SIZE = 100

    def process
      { success: true }
    end

    def write
      page_number = 0
      loop do
        is_last_page = process_and_write_page(page_number)
        break if is_last_page

        page_number += 1
      end
    end

    private

    def process_and_write_page(page_number)
      response = fetch_operaton_data(query_params: build_request_params(page_number * PAGE_SIZE))
      raise "Operaton pagination error: #{response&.code} - #{response&.parsed_response}" unless response&.success?

      records = response.parsed_response
      entities = normalize_response(records)
      write_entities(entities, page_number) if entities.any?

      records.empty? || records.size < PAGE_SIZE
    end

    def write_entities(entities, page_number)
      record_to_write = build_record(
        content: entities,
        page_index: page_number,
        total_pages: -1,
        total_records: -1
      )
      @shared_storage_writer.write(record_to_write)
    end

    ##
    # Builds the initial parameter hash for the request.
    #
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
        endpoint: process_options[:endpoint],
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
