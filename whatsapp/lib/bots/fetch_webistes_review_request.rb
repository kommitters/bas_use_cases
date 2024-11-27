# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/utils/postgres/request'

module Implementation
  ##
  # The Implementation::FetchWebsiteReviewRequest class serves as a bot implementation to fetch
  # web availability request from a postgres database
  class FetchWebsiteReviewRequest < Bas::Bot::Base
    def process
      requests = Utils::Postgres::Request.execute(params)
      urls = normalize_response(requests)

      { success: { urls: } }
    end

    private

    def params
      {
        connection: process_options[:connection],
        query:
      }
    end

    def normalize_response(requests)
      requests.map do |request|
        {
          url: request[:url]
        }
      end
    end

    def query
      "SELECT url
       FROM observed_websites AS ow INNER JOIN observed_websites_conversations AS owc ON ow.id = owc.observed_website_id
       WHERE url IS NOT NULL;
      "
    end
  end
end
