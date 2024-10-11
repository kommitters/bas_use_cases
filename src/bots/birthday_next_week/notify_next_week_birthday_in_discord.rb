# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifyNextWeekBirthdayInDiscord
  #
  class NotifyNextWeekBirthdayInDiscord < UseCase::Base
    TABLE = 'birthday'
    WEBHOOK = ENV.fetch('NEXT_WEEK_BIRTHDAY_DISCORD_WEBHOOK')
    BOT_NAME = ENV.fetch('DISCORD_BOT_NAME')

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FormatNextWeekBirthdays' },
        process_options: { webhook: WEBHOOK, name: BOT_NAME },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end
  end
end
