# frozen_string_literal: true

require 'bas/bot/base'
require 'date'
require 'httparty'

module Implementation
  ##
  # The Implementation::FetchPeopleWithMissingLogs class serves as a bot implementation to read work logs from
  # the kommit Work Logs platform and write them on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "missing_work_logs",
  #     tag: "FetchPeopleWithMissingLogs"
  #   }
  #
  #   options = {
  #     secret: "work_logs_api_secret",
  #     work_logs_url: "https://work_logs_url/api/v1/users/last_work_logs",
  #     days: 7
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #  Implementation::FetchPeopleWithMissingLogs.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FetchPeopleWithMissingLogs < Bas::Bot::Base
    # Process function to request the work logs users and the last time they added a log
    #
    def process
      response = fetch_last_work_logs

      if response.code == 200
        { success: { notification: normalize_response(response.parsed_response['data']) } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def fetch_last_work_logs
      HTTParty.get(process_options[:work_logs_url],
                   headers: { 'Authorization' => "Bearer #{process_options[:secret]}" })
    end

    def normalize_response(response)
      missing_logs_list = missing_logs(response).map { |log| "- #{log['name']} (#{last_recorded(log)})" }

      ":warning::alarm_clock: People with missing Work Logs in the last #{process_options[:days]} "\
      "days and the last time they added a log:\n\n#{missing_logs_list.join("\n")}\n\n" \
    end

    def missing_logs(logs)
      logs.filter do |log|
        date = DateTime.parse(log['last_recorded'])

        date < Date.today - process_options[:days] && date > Date.today - 60
      end
    end

    def last_recorded(log)
      date = DateTime.parse(log['last_recorded'])

      date.strftime('%d/%m/%Y')
    end
  end
end
