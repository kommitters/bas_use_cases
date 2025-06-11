# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'
require_relative '../utils/warehouse/notion/project_formatter'
require_relative '../utils/warehouse/notion/activity_formatter'
require_relative '../utils/warehouse/notion/work_item_formatter'

module Implementation
  ##
  # The Implementation::FetchRecordsFromNotionDatabase class provides a bot implementation
  # that reads records (such as projects) from a Notion database and saves them
  # into shared storage (e.g., PostgresDB).
  #
  # <b>Usage Example</b>
  #
  #   write_options = {
  #     connection: <DB_CONNECTION>,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchRecordsFromNotionDatabase'
  #   }
  #
  #   options = {
  #     database_id: ENV.fetch('PROJECT_NOTION_DATABASE_ID'),
  #     secret: ENV.fetch('NOTION_SECRET'),
  #     entity: 'project'
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
  #
  #   Implementation::FetchRecordsFromNotionDatabase
  #     .new(options, shared_storage_reader, shared_storage_writer)
  #     .execute
  #
  class FetchRecordsFromNotionDatabase < Bas::Bot::Base
    FORMATTERS = {
      'project' => Utils::Warehouse::Notion::Formatter::ProjectFormatter,
      'activity' => Utils::Warehouse::Notion::Formatter::ActivityFormatter,
      'work_item' => Utils::Warehouse::Notion::Formatter::WorkItemFormatter
    }.freeze

    PAGE_SIZE = 100

    # Proccess method fetches records from a Notion database based on the provided options.
    #
    def process
      entities = fetch_all_entities
      return entities if entities.is_a?(Hash) && entities[:error]

      build_paged_response(entities)
    end

    def write
      pages = process_response.dig(:success, :pages) || []
      pages.each do |page|
        next if @process_options[:avoid_empty_data] && page[:content].empty?

        record = build_record(page)
        @shared_storage_writer.write(record)
      end
    end

    private

    def build_paged_response(entities)
      paged_entities = entities.each_slice(PAGE_SIZE).to_a
      {
        success: {
          type: process_options[:entity],
          pages: paged_entities.each_with_index.map do |page, idx|
            build_page(page, idx, paged_entities.size, entities.size)
          end
        }
      }
    end

    def build_page(page, idx, total_pages, total_records)
      {
        content: page,
        page_index: idx + 1,
        total_pages: total_pages,
        total_records: total_records
      }
    end

    def build_record(page)
      {
        success: {
          type: process_options[:entity],
          **page
        }
      }
    end

    def error_response(response)
      {
        error: {
          message: response.parsed_response,
          status_code: response.code
        }
      }
    end

    # Fetches all additional entities if there are more pages in the Notion API.
    # If a paginated request fails, returns an error_response hash.
    def fetch_all_entities
      all_entities = []
      next_cursor = nil

      loop do
        response = fetch_notion_page(next_cursor)
        return error_response(response) unless response.code == 200

        all_entities += normalize_response(response.parsed_response['results'])
        break unless response.parsed_response['has_more']

        next_cursor = response.parsed_response['next_cursor']
      end

      all_entities
    end

    def fetch_notion_page(cursor = nil)
      request_body = body.dup
      request_body[:start_cursor] = cursor if cursor
      Utils::Notion::Request.execute(params.merge(body: request_body))
    end

    def params
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body:
      }
    end

    def body
      date_filter.empty? ? {} : { filter: { and: date_filter } }
    end

    def date_filter
      return [] if read_response.inserted_at.nil?

      [{
        timestamp: :last_edited_time,
        last_edited_time: { on_or_after: read_response.inserted_at }
      }]
    end

    def normalize_response(records)
      formatter_class = FORMATTERS[process_options[:entity]]
      records.map { |record| formatter_class.new(record).format }
    end
  end
end
