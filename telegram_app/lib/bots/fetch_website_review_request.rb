# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/read/default'
require 'bas/utils/postgres/request'
require 'bas/write/postgres'

module Bot
  ##
  # The Bot::FetchWebsiteReviewRequest class serves as a bot implementation to fetch
  # web availability request from a postgres database
  class FetchWebsiteReviewRequest < Bot::Base
    def read
      reader = Read::Default.new

      reader.execute
    end

    def process
      requests = Utils::Postgres::Request.execute(params)
      urls = normalize_response(requests.values)

      { success: { urls: } }
    end

    def write
      write = Write::Postgres.new(write_options, process_response)

      write.execute
    end

    private

    def params
      {
        connection: process_options[:connection],
        query: 'SELECT chat_id, url FROM websites WHERE chat_id IS NOT NULL AND url IS NOT NULL;'
      }
    end

    def normalize_response(requests)
      requests.map do |request|
        {
          chat_id: request[0],
          url: request[1]
        }
      end
    end
  end
end
