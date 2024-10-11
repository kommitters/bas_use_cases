# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/write_media_review_in_discord'

module UseCase
  # WriteMediaReviewInDiscord
  #
  class WriteMediaReviewInDiscord < UseCase::Base
    TABLE = 'review_images'
    DISCORD_BOT_TOKEN = ENV.fetch('DISCORD_BOT_TOKEN')

    def execute
      bot = Bot::WriteMediaReviewInDiscord.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'ReviewImage' },
        process_options: { secret_token: "Bot #{DISCORD_BOT_TOKEN}" },
        write_options: { connection:, db_table: TABLE, tag: 'WriteMediaReviewInDiscord' }
      }
    end
  end
end
