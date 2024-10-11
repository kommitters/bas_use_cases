# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifyDoBollAlertDiscord
  #
  class NotifyDoBollAlertDiscord < UseCase::Base
    TABLE = 'do_billing'
    DISCORD_BOT_NAME = ENV.fetch('DISCORD_BOT_NAME')

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FormatDoBillAlert' },
        process_options: { name: DISCORD_BOT_NAME, webhook: @discord_webhook },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end
  end
end
