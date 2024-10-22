# frozen_string_literal: true

require 'logger'
require_relative '../base'
require_relative '../../bots/telegram_bots/review_website_availability'

module UseCase
  # ReviewWebsiteAvailability
  #
  class ReviewWebsiteAvailability < UseCase::Base
    TABLE = 'telegram_web_availability'
    TELEGRAM_BOT_TOKEN = ENV.fetch('TELEGRAM_BOT_TOKEN')

    def execute
      bot = Bot::ReviewWebsiteAvailability.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchWebsiteReviewRequest' },
        process_options: { connection:, db_table: TABLE, tag: 'WebsiteAvailability' },
        write_options: { connection:, db_table: TABLE, tag: 'ReviewWebsiteAvailability' }
      }
    end
  end
end