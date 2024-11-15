# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/utils/postgres/request'

module Bot
  ##
  # The Bot::FetchWebsiteReviewRequest class serves as a bot implementation to fetch
  # web availability request from a postgres database
  class FetchWebsiteReviewRequest < Bas::Bot::Base
    def process
      requests = Utils::Postgres::Request.execute(params)
      urls = normalize_response(requests.values)

      { success: { urls: } }
    end

    private

    def params
      {
        connection: process_options[:connection],
        query: 'SELECT url FROM observed_websites WHERE url IS NOT NULL;'
      }
    end

    def normalize_response(requests)
      requests.map do |request|
        {
          url: request.first
        }
      end
    end
  end
end
