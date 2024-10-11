# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/review_media'

module UseCase
  # ReviewMedia
  #
  class ReviewMedia < UseCase::Base
    TABLE = 'review_images'
    REVIEW_IMAGE_OPENAI_ASSISTANT = ENV.fetch('REVIEW_IMAGE_OPENAI_ASSISTANT')
    OPENAI_SECRET = ENV.fetch('OPENAI_SECRET')

    def execute
      bot = Bot::ReviewMedia.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'ReviewMediaRequest' },
        process_options: { secret: OPENAI_SECRET, assistant_id: REVIEW_IMAGE_OPENAI_ASSISTANT, media_type: 'images' },
        write_options: { connection:, db_table: TABLE, tag: 'ReviewImage' }
      }
    end
  end
end
