# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/format_do_bill_alert'

module UseCase
  # FormatDoBillAlert
  #
  class FormatDoBillAlert < UseCase::Base
    TABLE = 'do_billing'

    def execute
      bot = Bot::FormatDoBillAlert.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchBillingFromDigitalOcean' },
        process_options: { threshold: },
        write_options: { connection:, db_table: TABLE, tag: 'FormatDoBillAlert' }
      }
    end

    def threshold
      ENV.fetch('DIGITAL_OCEAN_THRESHOLD').to_f
    end
  end
end
