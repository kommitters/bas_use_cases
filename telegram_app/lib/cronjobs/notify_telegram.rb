# frozen_string_literal: true

require 'logger'
require_relative '../../src/use_case/base'
require_relative '../../src/bots/notify_telegram'

module UseCase
  # NotifyTelegram
  #
  class NotifyTelegram < UseCase::Base
    TABLE = 'telegram_web_availability'
    TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN')

    def execute
      bot = Bot::NotifyTelegram.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'WebsiteAvailability' },
        process_options: { connection:, token: TELEGRAM_BOT_TOKEN },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyTelegram' }
      }
    end
  end
end