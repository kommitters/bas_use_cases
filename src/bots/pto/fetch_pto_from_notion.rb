# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_ptos_from_notion'

module UseCase
  # FetchPtoFromNotion
  #
  class FetchPtoFromNotion < UseCase::Base
    TABLE = 'pto'
    PTO_NOTION_DATABASE_ID = ENV.fetch('PTO_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def execute
      bot = Bot::FetchPtosFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id: PTO_NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'FetchPtosFromNotion' }
      }
    end
  end
end
