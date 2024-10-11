# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifySupportEmails
  #
  class NotifySupportEmails < UseCase::Base
    TABLE = 'support_emails'
    SUPPORT_EMAIL_DISCORD_WEBHOOK = ENV.fetch('SUPPORT_EMAIL_DISCORD_WEBHOOK')
    DISCORD_BOT_NAME = ENV.fetch('DISCORD_BOT_NAME')

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FormatEmails' },
        process_options: { webhook: SUPPORT_EMAIL_DISCORD_WEBHOOK, name: DISCORD_BOT_NAME },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end
  end
end
