# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_domains_wip_counts_from_notion'

module UseCase
  # FetchDomainsWipCountFromNotion
  #
  class FetchDomainsWipCountFromNotion < UseCase::Base
    TABLE = 'wip_limits'
    WIP_COUNT_NOTION_DATABASE_ID = ENV.fetch('WIP_COUNT_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def execute
      bot = Bot::FetchDomainsWipCountsFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id: WIP_COUNT_NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: @table_name, tag: 'FetchDomainsWipCountsFromNotion' }
      }
    end
  end
end
