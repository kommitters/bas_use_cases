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
    # Process function to execute the Notion utility to fetch birthdays from a notion database
    #
    def process
      response = Utils::Notion::Request.execute(params)
      return error_response(response) unless response.code == 200

      entities = normalize_response(response.parsed_response['results'])
      entities += fetch_all_entities(response) if response.parsed_response['has_more']

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

    def fetch_all_entities(response)
      entities = []

      loop do
        break unless response.parsed_response['has_more']

        response = Utils::Notion::Request.execute(next_cursor_params(response.parsed_response['next_cursor']))
        entities += normalize_response(response.parsed_response['results']) if response.code == 200
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
      if filter.nil? || filter.empty?
        {} # No incluye filter
      else
        { filter: filter }
      end
    end

    def filter_conditions
      []
    end

    def normalize_response(records)
      formatter = formatter_for_entity(process_options[:entity])
      records.map { |record| formatter.format(record) }
    end

    def formatter_for_entity(entity)
      case entity
      when 'project'
        Formatter::ProjectFormatter.new
      when 'activity'
        Formatter::ActivityFormatter.new
      when 'work_item'
        Formatter::WorkItemFormatter.new
      else
        raise "No formatter implemented for entity: #{entity}"
      end
    end
  end
end
