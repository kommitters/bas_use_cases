# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::FetchWorklogsFromNotion class serves as a bot implementation to read worklogs from a
  # notion database and write them on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "worklog",
  #     tag: "FetchWorklogsFromNotion"
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
  #  Implementation::FetchWorklogsFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchWorklogsFromNotion < Bas::Bot::Base
    # Process function to execute the Notion utility to fetch worklogs from a notion database
    #
    def process
      response = Utils::Notion::Request.execute(params)
      if response.code == 200
        worklogs_list = normalize_response(response.parsed_response['results'])
        grouped_worklogs = group_worklogs_by_person(worklogs_list)

        { success: { worklogs: grouped_worklogs } }
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
      today = Time.now.utc.strftime('%F').to_s

      {
        filter: {
          and: [{ property: 'Date', date: { equals: today } }] + last_edited_condition
        }
      }
    end

    def last_edited_condition
      return [] if read_response.inserted_at.nil?

      [
        {
          timestamp: 'last_edited_time',
          last_edited_time: { on_or_after: read_response.inserted_at }
        }
      ]
    end

    def normalize_response(results)
      return [] if results.nil?

      results.map { |value| map_notion_properties_to_worklog(value) }
    end

    def map_notion_properties_to_worklog(notion_result)
      properties = notion_result['properties']

      {

        'activity' => extract_select_field_value(properties['Activity']),
        'person_name' => extract_people_field_value(properties['Person']),
        'worklog_date' => extract_date_field_value(properties['Date']),
        'hours' => extract_number_field_value(properties['Hours']),
        'type' => extract_select_field_value(properties['Category']),
        'detail' => extract_rich_text(properties['Detail'])
      }
    end

    def group_worklogs_by_person(worklogs_list)
      worklogs_list.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |worklog, grouped|
        person = worklog['person_name'] || 'Unknown Person'
        grouped[person] << extract_relevant_worklog_data(worklog)
      end
    end

    def extract_relevant_worklog_data(worklog)
      {
        'activity' => worklog['activity'],
        'worklog_title' => worklog['worklog_title'],
        'worklog_date' => worklog['worklog_date'],
        'hours' => worklog['hours'],
        'type' => worklog['type'],
        'detail' => worklog['detail']
      }
    end

    # Helper methods for extracting values from Notion properties
    def extract_rich_text(data)
      if data && data['title'] && !data['title'].empty?
        data['title'][0]['plain_text']
      elsif data && data['rich_text'] && !data['rich_text'].empty?
        data['rich_text'][0]['plain_text']
      end
    end

    def extract_title_field_value(data)
      data['title'][0]['plain_text'] if data && data['title'] && data['title'][0]
    end

    def extract_date_field_value(data)
      data['date']['start'] if data && data['date']
    end

    def extract_number_field_value(data)
      data['number'] if data && data['number']
    end

    def extract_select_field_value(data)
      data['select']['name'] if data && data['select'] && data['select']['name']
    end

    def extract_people_field_value(data)
      data['people'][0]['name'] if data && data['people'] && data['people'][0]
    end
  end
end
