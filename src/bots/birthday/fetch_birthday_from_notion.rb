# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_birthdays_from_notion'

module UseCase
  # FetchBirthdayFromNotion
  #
  class FetchBirthdayFromNotion < UseCase::Base
    TABLE = 'birthday'
    NOTION_DATABASE_ID = ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def perform
      bot = Bot::FetchWebsiteReviewRequest.new(options)

      bot.execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion', avoid_process: true },
        process_options: { database_id: NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion' }
      }
    end
  end
end
