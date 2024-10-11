# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/format_do_bill_alert'

module UseCase
  # FormatDoBillAlert
  #
  class FormatDoBillAlert < UseCase::Base
    TABLE = 'do_billing'
    DIGITAL_OCEAN_THRESHOLD = ENV.fetch('DIGITAL_OCEAN_THRESHOLD')

    def execute
      bot = Bot::FormatDoBillAlert.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchBillingFromDigitalOcean' },
        process_options: { threshold: DIGITAL_OCEAN_THRESHOLD },
        write_options: { connection:, db_table: TABLE, tag: 'FormatDoBillAlert' }
      }
    end
  end
end
