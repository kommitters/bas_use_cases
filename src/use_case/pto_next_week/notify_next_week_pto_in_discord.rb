# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/notify_discord'

module UseCase
  # NotifyNextWeekPtoInDiscord
  #
  class NotifyNextWeekPtoInDiscord < UseCase::Base
    TABLE = 'pto'
    NEXT_WEEK_PTO_DISCORD_WEBHOOK = ENV.fetch('NEXT_WEEK_PTO_DISCORD_WEBHOOK')
    DISCORD_BOT_NAME = ENV.fetch('DISCORD_BOT_NAME')

    def execute
      bot = Bot::NotifyDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'HumanizeNextWeekPto' },
        process_options: { webhook: NEXT_WEEK_PTO_DISCORD_WEBHOOK, name: DISCORD_BOT_NAME },
        write_options: { connection:, db_table: TABLE, tag: 'NotifyDiscord' }
      }
    end

    def prompt
      utc_today = Time.now.utc
      today = Time.at(utc_today, in: '-05:00').strftime('%A, %B %m of %Y').to_s

      "Today is #{today} and the PTO's are: {data} Notify only the PTOs of the next week and nothing else"
    end
  end
end
