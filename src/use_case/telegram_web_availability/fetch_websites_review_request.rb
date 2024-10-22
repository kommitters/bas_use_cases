# frozen_string_literal: true

require 'logger'
require_relative '../base'
require_relative '../../bots/telegram_bots/fetch_website_review_request'

module UseCase
  # FetchWebsiteReviewRequest
  #
  class FetchWebsiteReviewRequest < UseCase::Base
    TABLE = 'websites'
    TELEGRAM_TABLE = 'telegram_web_availability'

    def execute
      bot = Bot::FetchWebsiteReviewRequest.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { connection:, db_table: TABLE, tag: 'ReviewTextRequest' },
        write_options: { connection:, db_table: TELEGRAM_TABLE, tag: 'FetchWebsiteReviewRequest' }
      }
    end
  end
end