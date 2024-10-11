# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_birthdays_from_notion'

module UseCase
  # FetchNextWeekBirthdayFromNotion
  #
  class FetchNextWeekBirthdayFromNotion < UseCase::Base
    TABLE = 'birthday'
    NOTION_DATABASE_ID = ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def execute
      bot = Bot::FetchNextWeekBirthdaysFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekBirthdaysFromNotion',
                        avoid_process: true },
        process_options: { database_id: NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekBirthdaysFromNotion' }
      }
    end
  end
end
