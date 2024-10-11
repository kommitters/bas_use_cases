# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/compare_wip_limit_count'

module UseCase
  # CompareWipLimitCount
  #
  class CompareWipLimitCount < UseCase::Base
    TABLE = 'wip_limits'

    def execute
      bot = Bot::CompareWipLimitCount.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchDomainsWipLimitFromNotion' },
        write_options: { connection:, db_table: TABLE, tag: 'CompareWipLimitCount' }
      }
    end
  end
end
