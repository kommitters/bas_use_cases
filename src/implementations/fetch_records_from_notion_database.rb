# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'
require_relative '../utils/warehouse/notion/activity_formatter'
require_relative '../utils/warehouse/notion/document_formatter'
require_relative '../utils/warehouse/notion/domain_formatter'
require_relative '../utils/warehouse/notion/key_result_formatter'
require_relative '../utils/warehouse/notion/milestone_formatter'
require_relative '../utils/warehouse/notion/person_formatter'
require_relative '../utils/warehouse/notion/project_formatter'
require_relative '../utils/warehouse/notion/weekly_scope_formatter'
require_relative '../utils/warehouse/notion/work_item_formatter'

module Implementation
  ##
  # Implementation::FetchRecordsFromNotionDatabase
  #
  # This class implements a bot that fetches records (such as projects, activities, or work items)
  # from a Notion database and saves them into shared storage (e.g., PostgresDB).
  #
  # <b>Usage Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     avoid_process: true,
  #     where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  #     params: [false, 'FetchProjectsFromNotionDatabase']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchProjectsFromNotionDatabase'
  #   }
  #
  #   options = {
  #     database_id: ENV.fetch('PROJECT_NOTION_DATABASE_ID'),
  #     secret: ENV.fetch('NOTION_SECRET'),
  #     entity: 'project'
  #   }
  #
  #    shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  #   Implementation::FetchRecordsFromNotionDatabase
  #     .new(options, shared_storage)
  #     .execute
  #
  class FetchRecordsFromNotionDatabase < Bas::Bot::Base
    FORMATTERS = {
      'activity' => Utils::Warehouse::Notion::Formatter::ActivityFormatter,
      'document' => Utils::Warehouse::Notion::Formatter::DocumentFormatter,
      'domain' => Utils::Warehouse::Notion::Formatter::DomainFormatter,
      'key_result' => Utils::Warehouse::Notion::Formatter::KeyResultFormatter,
      'milestone' => Utils::Warehouse::Notion::Formatter::MilestoneFormatter,
      'person' => Utils::Warehouse::Notion::Formatter::PersonFormatter,
      'project' => Utils::Warehouse::Notion::Formatter::ProjectFormatter,
      'weekly_scope' => Utils::Warehouse::Notion::Formatter::WeeklyScopeFormatter,
      'work_item' => Utils::Warehouse::Notion::Formatter::WorkItemFormatter
    }.freeze

    PAGE_SIZE = 100

    # Proccess method fetches records from a Notion database based on the provided options.
    #
    def process
      entities = fetch_all_main_entities
      return entities if entities.is_a?(Hash)
      return { success: { type: entity_type, content: [] } } if entities.empty?

      result = { type: entity_type, content: entities }

      add_nested_milestones_if_applicable(result)

      { success: result }
    end

    def write
      write_entity(process_response.dig(:success, :type), process_response.dig(:success, :content))
      nested = process_response.dig(:success, :nested)
      return unless nested

      write_entity(nested[:type], nested[:content])
    end

    def write_entity(type, content)
      paged_entities = content.each_slice(PAGE_SIZE).to_a
      paged_entities.each_with_index do |page, idx|
        record = {
          success: {
            type: type, content: page, page_index: idx + 1,
            total_pages: paged_entities.size, total_records: content.size
          }
        }
        @shared_storage_writer.write(record)
      end
    end

    private

    def fetch_all_main_entities
      all_entities = []
      next_cursor = nil
      loop do
        records, next_cursor, error = fetch_and_process_page(next_cursor)
        return error if error

        all_entities.concat(records)
        break unless next_cursor
      end

      all_entities
    end

    def fetch_and_process_page(cursor)
      request_body = body
      request_body[:start_cursor] = cursor if cursor

      response = notion_request(endpoint: "databases/#{process_options[:database_id]}/query", body: request_body)
      return [nil, nil, error_response(response)] unless response.code == 200

      records = normalize_response(response.parsed_response['results'])
      new_cursor = response.parsed_response['has_more'] ? response.parsed_response['next_cursor'] : nil

      [records, new_cursor, nil]
    end

    def add_nested_milestones_if_applicable(result_hash)
      return unless process_options[:entity] == 'project'

      projects = result_hash[:content]
      milestones = FORMATTERS['milestone'].fetch_for_projects(projects, secret: process_options[:secret])

      result_hash[:nested] = { type: 'milestone', content: milestones } if milestones.any?
    end

    def entity_type
      process_options[:entity]
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

    def notion_request(endpoint:, method: 'post', body: {})
      Utils::Notion::Request.execute(endpoint: endpoint, secret: process_options[:secret], method: method, body: body)
    end

    def build_record(content:, page_index:, total_pages:, total_records:)
      {
        success: {
          type: process_options[:entity], content: content, page_index: page_index,
          total_pages: total_pages, total_records: total_records
        }
      }
    end

    def error_response(response)
      { error: {
        message: response.parsed_response, status_code: response.code
      } }
    end
  end
end
