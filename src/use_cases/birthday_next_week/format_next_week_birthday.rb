# frozen_string_literal: true

require 'bas/bot/format_birthdays'
require 'json'

module Format
  # Service to format birthdays
  class NextWeekBirthday
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

      bot = Bot::FormatBirthdays.new(options)

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
        tag: 'FetchNextWeekBirthdaysFromNotion'
      }
    end

    def process_options
      {
        template: ':birthday: :gift: The birthday of <name> will be in eight days! : <birthday_date>'
      }
    end

    def write_options
      {
        connection:,
        db_table: @table_name,
        tag: 'FormatNextWeekBirthdays'
      }
    end
  end
end
