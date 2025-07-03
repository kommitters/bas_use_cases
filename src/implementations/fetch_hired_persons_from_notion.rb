# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'
require_relative '../utils/warehouse/notion/hired_person_formatter'
require_relative '../services/postgres/person'

module Implementation
  ##
  # Implementation::FetchHiredPersonsFromNotionDatabase
  #
  # This class implements a bot that fetches records (such as projects, activities, or work items)
  # from a Notion database and saves them into shared storage (e.g., PostgresDB).
  #
  # <b>Usage Example</b>
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'warehouse_sync',
  #     tag: 'FetchHiredPersonsFromNotionDatabase'
  #   }

  #   options = {
  #     database_id: Config::HIRED_PERSONS_NOTION_DATABASE_ID,
  #     secret: Config::NOTION_SECRET,
  #     entity: 'person'
  #   }
  #
  #    shared_storage_reader = Bas::SharedStorage::Default.new
  #    shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  #   Implementation::FetchHiredPersonsFromNotionDatabase
  #   .new(options, shared_storage_reader, shared_storage_writer)
  #   .execute
  #
  class FetchHiredPersonsFromNotionDatabase < Bas::Bot::Base
    PAGE_SIZE = 100
    # Proccess method fetches records from a Notion database based on the provided options.
    #
    def process
      response = notion_request(endpoint: "databases/#{process_options[:database_id]}/query", body: body)
      return error_response(response) unless response.code == 200

      records = response.parsed_response['results']
      records.concat(fetch_all_pages(response)) if response.parsed_response['has_more']

      entities = normalize_response(records)

      { success: { type: process_options[:entity], content: entities } }
    end

    def write
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

    def normalize_response(records)
      formatter_class = Utils::Warehouse::Notion::Formatter::HiredPersonFormatter
      formatted_records = records.map { |record| formatter_class.new(record).format }
      formatted_records.map { |person_data| add_id_to_person(person_data) }
    end

    def add_id_to_person(person_data)
      email = person_data[:email_address]
      unless email && !email.strip.empty?
        person_data[:warehouse_id] = -1
        return person_data
      end
      person_service = Services::Postgres::Person.new(process_options[:db])
      warehouse_person = person_service.query({ email_address: email }).first
      person_data[:warehouse_id] = warehouse_person ? warehouse_person[:id] : -1

      person_data
    end

    def fetch_all_pages(initial_response) # rubocop:disable Metrics/MethodLength
      all_records = []
      response = initial_response

      loop do
        break unless response.parsed_response['has_more']

        next_cursor = response.parsed_response['next_cursor']
        response = notion_request(endpoint: "databases/#{process_options[:database_id]}/query",
                                  body: body.merge({ start_cursor: next_cursor }))
        break unless response.code == 200

        all_records.concat(response.parsed_response['results'])
      end

      all_records
    end

    def notion_request(endpoint:, body: {})
      Utils::Notion::Request.execute(
        endpoint: endpoint,
        secret: process_options[:secret],
        method: 'post',
        body: body
      )
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
      {
        error: {
          message: response.parsed_response,
          status_code: response.code
        }
      }
    end
  end
end
