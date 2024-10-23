# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifyDoBillAlertDiscord
  #
  class NotifyDoBillAlertDiscord < UseCase::Base
    TABLE = 'do_billing'

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FormatDoBillAlert' },
        process_options: { name:, webhook: @discord_webhook },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end

    def name
      ENV.fetch('DISCORD_BOT_NAME')
    end
  end
end
