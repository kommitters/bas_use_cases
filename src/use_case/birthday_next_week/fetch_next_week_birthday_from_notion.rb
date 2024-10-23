# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_next_week_birthdays_from_notion'

module UseCase
  # FetchNextWeekBirthdayFromNotion
  #
  class FetchNextWeekBirthdayFromNotion < UseCase::Base
    TABLE = 'birthday'

    def execute
      bot = Bot::FetchNextWeekBirthdaysFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekBirthdaysFromNotion', avoid_process: true },
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekBirthdaysFromNotion' }
      }
    end

    def database_id
      ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
