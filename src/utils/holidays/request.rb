# frozen_string_literal: true

require 'httparty'
require 'json'
require 'dotenv/load'

module Utils
  module Holidays
    #
    # Request class to get the holidays list for a given country and year
    #
    class Request
      #
      # Get the holidays list for a given country and year
      #
      # @param country [String] The country code
      # @param year [Integer] The year
      #
      def initialize(country: 'CO', year: Time.now.year - 1, month: Time.now.month, day: Time.now.day)
        @country = country
        @year = year
        @month = month
        @day = day
      end

      #
      # Execute the request to get the holidays list
      #
      # @return [Hash] The holidays list with the following keys:
      #   - holidays: An array of holidays. Each holiday is a hash with the following keys:
      #     - name: The name of the holiday
      #     - date: The date of the holiday in format YYYY-MM-DD
      #     - observed: The observed date of the holiday in format YYYY-MM-DD
      #     - public: Whether the holiday is public
      #     - country: The country code
      #
      def execute
        response = HTTParty.get(
          'https://holidayapi.com/v1/holidays',
          query: params
        )

        return JSON.parse(response.body) if response.code == 200

        { error: "Failed to fetch holidays. #{error_description(response)}" }
      end

      private

      def error_description(response)
        description = "HTTP error: #{response.code}. "

        begin
          description += JSON.parse(response.body)['error']
        rescue StandardError
          description += 'Unknown error'
        end

        description.strip
      end

      def params
        {
          key: ENV.fetch('HOLIDAYS_API_KEY', nil),
          country: @country,
          year: @year,
          month: @month,
          day: @day,
          upcoming: true,
          pretty: true
        }
      end
    end
  end
end
