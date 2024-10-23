# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/review_media'

module UseCase
  # ReviewMedia
  #
  class ReviewMedia < UseCase::Base
    TABLE = 'review_images'

    def execute
      bot = Bot::ReviewMedia.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'ReviewMediaRequest' },
        process_options: { secret:, assistant_id:, media_type: 'images' },
        write_options: { connection:, db_table: TABLE, tag: 'ReviewImage' }
      }
    end

    def secret
      ENV.fetch('OPENAI_SECRET')
    end

    def assistant_id
      ENV.fetch('REVIEW_IMAGE_OPENAI_ASSISTANT')
    end
  end
end
