# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifyBirthdayInDiscord
  #
  class NotifyBirthdayInDiscord < UseCase::Base
    TABLE = 'birthday'
    DISCORD_WEBHOOK = ENV.fetch('BIRTHDAY_DISCORD_WEBHOOK')
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
        read_options: { connection:, db_table: TABLE, tag: 'FormatBirthdays' },
        process_options: { webhook: DISCORD_WEBHOOK, name: DISCORD_BOT_NAME },
        write_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion' }
      }
    end
  end
end
