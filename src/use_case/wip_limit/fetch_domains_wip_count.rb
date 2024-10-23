# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_domains_wip_counts_from_notion'

module UseCase
  # FetchDomainsWipCountFromNotion
  #
  class FetchDomainsWipCountFromNotion < UseCase::Base
    TABLE = 'wip_limits'

    def execute
      bot = Bot::FetchDomainsWipCountsFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchDomainsWipCountsFromNotion' }
      }
    end

    def database_id
      ENV.fetch('WIP_COUNT_NOTION_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
