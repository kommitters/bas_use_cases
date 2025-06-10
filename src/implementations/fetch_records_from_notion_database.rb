# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'
require_relative '../utils/warehouse/notion/projects'
require_relative '../utils/warehouse/notion/activities'
require_relative '../utils/warehouse/notion/work_items'

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
    # Procces method fetches records from a Notion database based on the provided options.
    #
    def process
      response = Utils::Notion::Request.execute(params)
      return error_response(response) unless response.code == 200

      entities = normalize_response(response.parsed_response['results'])
      if response.parsed_response['has_more']
        paginated_entities = fetch_all_entities(response)

        return paginated_entities if paginated_entities.is_a?(Hash) && paginated_entities[:error]

        entities += paginated_entities
      end

      success_response(entities)
    end

    private

    def success_response(entities)
      {
        success:
        {
          type: process_options[:entity],
          content: entities
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
    def fetch_all_entities(initial_response)
      entities = []
      response = initial_response

      loop do
        break unless response.parsed_response['has_more']

        next_response = Utils::Notion::Request.execute(next_cursor_params(response.parsed_response['next_cursor']))

        return error_response(next_response) unless next_response.code == 200

        entities += normalize_response(next_response.parsed_response['results'])
        response = next_response
      end

      entities
    end

    def params
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body:
      }
    end

    def next_cursor_params(next_cursor)
      next_cursor_body = body.merge({ start_cursor: next_cursor })

      params.merge(body: next_cursor_body)
    end

    def body
      filter = filter_conditions
      filter.nil? || filter.empty? ? {} : { filter: filter }
    end

    def filter_conditions
      []
    end

    def normalize_response(records)
      formatter = formatter_for_entity(process_options[:entity])
      records.map { |record| formatter.format(record) }
    end

    # Returns the correct formatter for the given entity, or raises if not implemented.
    FORMATTERS = {
      'project' => Formatter::ProjectFormatter,
      'activity' => Formatter::ActivityFormatter,
      'work_item' => Formatter::WorkItemFormatter
    }.freeze

    def formatter_for_entity(entity)
      formatter = FORMATTERS[entity]
      raise "No formatter implemented for entity: #{entity}" unless formatter

      formatter.new
    end
  end
end
