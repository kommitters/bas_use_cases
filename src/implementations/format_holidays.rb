# frozen_string_literal: true

require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FormatHolidays class serves as a bot implementation
  # to format the holidays data
  #
  class FormatHolidays < Bas::Bot::Base
    def process
      return { error: { message: 'No holidays data found' } } if read_response.nil?

      data = read_response.data
      return { error: { message: 'No holidays data found' } } unless data.is_a?(Hash)
      unless data.key?('holidays') && data['holidays'].is_a?(Array) && data['holidays'].any?
        return { error: { message: 'No holidays data found' } }
      end

      { success: { notification: notification_content(data['holidays']) } }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    def notification_content(holidays)
      holidays.reduce(process_options[:title]) do |accumulator, holiday|
        "#{accumulator}\n- #{holiday['name']} on #{humanize_date(holiday['date'])}"
      end
    end

    def humanize_date(date)
      original_date = Date.parse(date)
      Date.new(Time.now.year, original_date.month, original_date.day).strftime('%B %d')
    end
  end
end
