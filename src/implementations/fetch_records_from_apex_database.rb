# frozen_string_literal: true

require 'bas/bot/base'
require 'time'
require_relative '../utils/warehouse/apex/request'
require_relative '../utils/warehouse/apex/activity_formatter'
require_relative '../utils/warehouse/apex/domain_formatter'
require_relative '../utils/warehouse/apex/people_formatter'
require_relative '../utils/warehouse/apex/project_formatter'
require_relative '../utils/warehouse/apex/work_item_formatter'
require_relative '../utils/warehouse/apex/okr_formatter'
require_relative '../utils/warehouse/apex/kr_formatter'
require_relative '../utils/warehouse/apex/milestone_formatter'
require_relative '../utils/warehouse/apex/organizational_unit_formatter'
require_relative '../utils/warehouse/apex/process_formatter'
require_relative '../utils/warehouse/apex/task_formatter'
require_relative '../utils/warehouse/apex/weekly_scope_formatter'
require_relative '../utils/warehouse/apex/weekly_scope_task_formatter'

module Implementation
  ##
  # This bot implements the logic to fetch records from an APEX database's
  # endpoints, handles pagination, and saves them into the shared storage.
  #
  class FetchRecordsFromApexDatabase < Bas::Bot::Base
    FORMATTERS = {
      'domain' => Utils::Warehouse::Apex::Formatter::DomainFormatter,
      'activity' => Utils::Warehouse::Apex::Formatter::ActivityFormatter,
      'people' => Utils::Warehouse::Apex::Formatter::PeopleFormatter,
      'project' => Utils::Warehouse::Apex::Formatter::ProjectFormatter,
      'work_item' => Utils::Warehouse::Apex::Formatter::WorkItemFormatter,
      'okr' => Utils::Warehouse::Apex::Formatter::OkrFormatter,
      'kr' => Utils::Warehouse::Apex::Formatter::KrFormatter,
      'apex_milestone' => Utils::Warehouse::Apex::Formatter::MilestoneFormatter,
      'organizational_unit' => Utils::Warehouse::Apex::Formatter::OrganizationalUnitFormatter,
      'process' => Utils::Warehouse::Apex::Formatter::ProcessFormatter,
      'task' => Utils::Warehouse::Apex::Formatter::TaskFormatter,
      'weekly_scope' => Utils::Warehouse::Apex::Formatter::WeeklyScopeFormatter,
      'weekly_scope_task' => Utils::Warehouse::Apex::Formatter::WeeklyScopeTaskFormatter
    }.freeze

    PAGE_SIZE = 100

    ##
    # Main method that fetches all data, handling pagination.
    #
    def process
      response = fetch_apex_data(build_request_params)
      return error_response(response) unless response.success?

      records = response.parsed_response['items'] || []

      records.concat(fetch_all_pages(response)) if response.parsed_response['hasMore']
      entities = normalize_response(records)

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

    ##
    # Loops through all remaining API pages and accumulates the records.
    #
    def fetch_all_pages(initial_response)
      all_records = []
      current_response = initial_response
      base_params = build_request_params

      # Loop while the API indicates there are more pages
      while current_response.parsed_response['hasMore']
        response = fetch_next_page(current_response, base_params)

        # Fail fast if a paginated request fails (suggestion from the bot)
        raise "APEX pagination error: #{response&.code} - #{response&.parsed_response}" unless response&.success?

        all_records.concat(response.parsed_response['items'] || [])
        current_response = response
      end

      all_records
    end

    ##
    # Fetches the next page of results based on the current response.
    #
    def fetch_next_page(current_response, base_params)
      parsed_body = current_response.parsed_response

      # Calculate the offset for the next page
      next_offset = parsed_body['offset'] + parsed_body['limit']

      # Prepare params and fetch the data
      paginated_params = base_params.merge(offset: next_offset)
      fetch_apex_data(paginated_params)
    end

    ##
    # Builds the initial parameter hash for the request.
    #
    def build_request_params
      params = {}
      params[:last_update_date] = Time.parse(read_response.inserted_at).utc.iso8601 if read_response.inserted_at
      params
    end

    ##
    # Executes a request to the APEX API.
    #
    def fetch_apex_data(params)
      Utils::Apex::Request.execute(
        endpoint: process_options[:endpoint],
        params: params
      )
    end

    ##
    # Uses the correct formatter to transform the raw data from APEX.
    #
    def normalize_response(records)
      formatter_class = FORMATTERS[process_options[:entity]]
      raise "Formatter not found for entity: '#{process_options[:entity]}'" unless formatter_class

      records.map { |record| formatter_class.new(record).format }
    end

    ##
    # Builds the record that will be saved in the shared storage.
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
      raise ArgumentError, "APEX API error (#{response.code}): #{response.message}"
    end
  end
end
