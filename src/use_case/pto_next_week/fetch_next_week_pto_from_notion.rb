# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_next_week_ptos_from_notion'

module UseCase
  # FetchNextWeekPtoFromNotion
  #
  class FetchNextWeekPtoFromNotion < UseCase::Base
    TABLE = 'pto'

    def execute
      bot = Bot::FetchNextWeekPtosFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekPtosFromNotion' }
      }
    end

    def database_id
      ENV.fetch('PTO_NOTION_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
