# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/humanize_pto'

module UseCase
  # NotifyPtoInDiscord
  #
  class NotifyPtoInDiscord < UseCase::Base
    TABLE = 'pto'
    PTO_DISCORD_WEBHOOK = ENV.fetch('PTO_DISCORD_WEBHOOK')
    DISCORD_BOT_NAME = ENV.fetch('DISCORD_BOT_NAME')

    def perform
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'HumanizePto' },
        process_options: { webhook: PTO_DISCORD_WEBHOOK, name: DISCORD_BOT_NAME },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end
  end
end
