# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/format_wip_limit_exceeded'

module UseCase
  # FormatWipLimitExceeded
  #
  class FormatWipLimitExceeded < UseCase::Base
    TABLE = 'wip_limits'
    TEMPLATE = ':warning: The <domain> WIP limit was exceeded by <exceeded>'

    def execute
      bot = Bot::FormatWipLimitExceeded.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'CompareWipLimitCount' },
        process_options: { template: TEMPLATE },
        write_options: { connection:, db_table: TABLE, tag: 'FormatWipLimitExceeded' }
      }
    end
  end
end
