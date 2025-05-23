# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'
require 'date'
require 'time'

module Implementation
  ##
  # The Implementation::FetchExpiredProjects class serves as a bot implementation to read expired projects from a
  # notion database and write them on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "expired_projects",
  #     tag: "ExpiredProjectsFromNotion"
  #   }
  #
  #   options = {
  #     database_id: "notion_database_id",
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #   Implementation::FetchExpiredProjects.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchExpiredProjects < Bas::Bot::Base
    def process
      response = Utils::Notion::Request.execute(params)

      if response.code == 200
        projects = normalize_response(response.parsed_response['results'])
        puts "Projects => #{projects}"

        { success: { projects_expired: projects } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def params
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body:
      }
    end

    def body
      {
        filter: {
          and: [
            status_filter,
            deadline_filter
          ]
        }
      }
    end

    def status_filter
      {
        property: 'Status',
        status: { equals: 'In progress' }
      }
    end

    def deadline_filter
      {
        property: 'Deadline',
        date: { before: Time.now.utc.strftime('%F') }
      }
    end

    def normalize_response(results)
      return [] if results.nil? || !results.is_a?(Array)

      results.map do |record|
        {
          id: record['id'],
          title: extract_title(record),
          deadline: extract_deadline(record),
          status: record.dig('properties', 'Status', 'status', 'name'),
          fetched_at: Time.now.utc.iso8601
        }
      end
    end

    def extract_deadline(record)
      record.dig('properties', 'Deadline', 'date', 'start')
    end

    def extract_title(record)
      title_array = record.dig('properties', 'Name', 'title')
      return '' unless title_array.is_a?(Array)

      title_array.map { |t| t['plain_text'] }.join(' ')
    end
  end
end
