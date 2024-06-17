# frozen_string_literal: true

require 'date'
require 'bas/bot/format_emails'
require 'json'

module Format
  # Service to format support emails
  class EmailsFromImap
    def initialize(params)
      @table_name = params[:table_name]
      @db_host = params[:db_host]
      @db_port = params[:db_port]
      @db_name = params[:db_name]
      @db_user = params[:db_user]
      @db_password = params[:db_password]
    end

    def execute
      options = { read_options:, process_options:, write_options: }

      bot = Bot::FormatEmails.new(options)

      bot.execute
    end

    private

    def connection
      {
        host: @db_host,
        port: @db_port,
        dbname: @db_name,
        user: @db_user,
        password: @db_password
      }
    end

    def read_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FetchEmailsFromImap'
      }
    end

    def process_options
      {
        template: 'The <sender> has requested support the <date>',
        timezone: '-05:00',
        frequency: notification_frequency
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FormatEmails'
      }
    end

    def notification_frequency
      current_time = Time.now.utc

      return 16 if current_time < target_hour(13)
      return 3 if current_time < target_hour(16)
      return 5 if current_time < target_hour(21)

      24
    end

    def target_hour(hour)
      current_time = Time.now.utc

      Time.utc(current_time.year, current_time.month, current_time.day, hour, 1, 0)
    end
  end
end
