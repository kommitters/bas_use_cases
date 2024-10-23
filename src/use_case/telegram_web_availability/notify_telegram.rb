# frozen_string_literal: true

require 'logger'
require_relative '../base'
require_relative '../../bots/telegram_bots/notify_telegram'

module UseCase
  # NotifyTelegram
  #
  class NotifyTelegram < UseCase::Base
    TABLE = 'telegram_web_availability'

    def execute
      bot = Bot::NotifyTelegram.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'WebsiteAvailability' },
        process_options: { connection:, token: },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyTelegram' }
      }
    end

    def token
      ENV.fetch('TELEGRAM_BOT_TOKEN')
    end
  end
end
