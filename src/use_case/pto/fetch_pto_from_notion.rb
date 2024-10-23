# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_ptos_from_notion'

module UseCase
  # FetchPtoFromNotion
  #
  class FetchPtoFromNotion < UseCase::Base
    TABLE = 'pto'

    def execute
      bot = Bot::FetchPtosFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchPtosFromNotion' }
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
