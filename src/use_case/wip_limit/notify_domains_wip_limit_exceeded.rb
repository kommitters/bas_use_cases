# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # FormatWipLimitExceeded
  #
  class NotifyDomainsWipLimitExceeded < UseCase::Base
    TABLE = 'wip_limits'

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FormatWipLimitExceeded' },
        process_options: { webhook:, name: },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end

    def webhook
      ENV.fetch('WIP_LIMIT_DISCORD_WEBHOOK')
    end

    def name
      ENV.fetch('DISCORD_BOT_NAME')
    end
  end
end
