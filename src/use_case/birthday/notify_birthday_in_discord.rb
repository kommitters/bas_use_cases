# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifyBirthdayInDiscord
  #
  class NotifyBirthdayInDiscord < UseCase::Base
    TABLE = 'birthday'

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FormatBirthdays' },
        process_options: { webhook:, name: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion' }
      }
    end

    def webhook
      ENV.fetch('BIRTHDAY_DISCORD_WEBHOOK')
    end

    def name
      ENV.fetch('DISCORD_BOT_NAME')
    end
  end
end
