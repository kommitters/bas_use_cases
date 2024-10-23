# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_domains_wip_limit_from_notion'

module UseCase
  # FetchDomainsWipLimitFromNotion
  #
  class FetchDomainsWipLimitFromNotion < UseCase::Base
    TABLE = 'wip_limits'

    def execute
      bot = Bot::FetchDomainsWipLimitFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchDomainsWipCountsFromNotion' },
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchDomainsWipLimitFromNotion' }
      }
    end

    def database_id
      ENV.fetch('WIP_LIMIT_NOTION_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
