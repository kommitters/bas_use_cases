# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_next_week_ptos_from_notion'

module UseCase
  # FetchNextWeekPtoFromNotion
  #
  class FetchNextWeekPtoFromNotion < UseCase::Base
    TABLE = 'pto'
    PTO_NOTION_DATABASE_ID = ENV.fetch('PTO_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def perform
      bot = Bot::FetchNextWeekPtosFromNotion.new(options)

      bot.execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    private

    def options
      {
        process_options: { database_id: PTO_NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekPtosFromNotion' }
      }
    end
  end
end
