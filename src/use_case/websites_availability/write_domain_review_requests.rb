# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/write_domain_review_requests'

module UseCase
  # WriteDomainReviewRequests
  #
  class WriteDomainReviewRequests < UseCase::Base
    TABLE = 'web_availability'

    def execute
      bot = Bot::WriteDomainReviewRequests.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchDomainServicesFromNotion' },
        process_options: { connection:, db_table: TABLE, tag: 'ReviewDomainRequest' },
        write_options: { connection:, db_table: TABLE, tag: 'WriteDomainReviewRequests' }
      }
    end
  end
end
