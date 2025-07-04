# frozen_string_literal: true

require 'bas/bot/base'

require_relative '../utils/holidays/request'

module Implementation
  #
  # The Implementation::FetchHolidays class serves as a bot implementation
  # to fetch the holidays list for a given country and year
  #
  class FetchHolidays < Bas::Bot::Base
    #
    # Process function to fetch the holidays list for a given country and year
    #
    def process
      response = Utils::Holidays::Request.new(
        country: process_options[:country],
        year: process_options[:year], month: process_options[:month], day: process_options[:day]
      ).execute

      if response.is_a?(Hash) && response['holidays']
        { success: { holidays: response['holidays'] } }
      else
        { error: { message: response[:error] } }
      end
    end
  end
end
