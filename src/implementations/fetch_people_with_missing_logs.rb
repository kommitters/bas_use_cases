# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/shared_storage/postgres'
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
        create_notifications(response.parsed_response['data'])

        { success: '' }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def fetch_last_work_logs
      HTTParty.get(process_options[:work_logs_url],
                   headers: { 'Authorization' => "Bearer #{process_options[:secret]}" })
    end

    def create_notifications(response)
      with_missing_logs(response).group_by { |person| person['domain'] }.map do |domain, people|
        notification = format_notification(domain, people)

        create_notification(domain, notification)
      end
    end

    def with_missing_logs(people)
      people.filter do |person|
        date = DateTime.parse(person['last_recorded'])

        date < Date.today - process_options[:days] && date > Date.today - 60
      end
    end

    def format_notification(domain, people)
      people = people.map { |person| "- #{person['name']} (#{last_recorded(person)})" }

      ":warning::alarm_clock: Hello director of **#{domain}**,\nThis is a notification regarding team members with missing"\
      " work-logs in the past #{process_options[:days]} days along with the date of their most recent entry:"\
      " \n\n#{people.join("\n")}\n\n" \
    end

    def last_recorded(log)
      date = DateTime.parse(log['last_recorded'])

      date.strftime('%d/%m/%Y')
    end

    def create_notification(domain, notification)
      write_data = { success: { notification:, dm_id: directors_dms(domain) } }

      shared_storage_writer.write(write_data)
    end

    def directors_dms(domain)
      case domain
      when /kommit\.admin/ then process_options[:admin_dm_id]
      when /kommit\.ops/ then process_options[:ops_dm_id]
      when /kommit\.engineering/ then process_options[:engineering_dm_id]
      when /kommit\.bizdev/ then process_options[:bizdev_dm_id]
      end
    end
  end
end
