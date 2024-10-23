# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_birthdays_from_notion'

module UseCase
  # FetchBirthdayFromNotion
  #
  class FetchBirthdayFromNotion < UseCase::Base
    TABLE = 'birthday'

    def execute
      bot = Bot::FetchBirthdaysFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion', avoid_process: true },
        process_options: { database_id: notion_database_id, secret: notion_secret },
        write_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion' }
      }
    end

    def notion_database_id
      ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID')
    end

    def notion_secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
