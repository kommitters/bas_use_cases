# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_billing_from_digital_ocean'

module UseCase
  # FetchBillingFromDigitalOcean
  #
  class FetchBillingFromDigitalOcean < UseCase::Base
    TABLE = 'do_billing'
    DIGITAL_OCEAN_SECRET = ENV.fetch('DIGITAL_OCEAN_SECRET')

    def perform
      bot = Bot::FetchBillingFromDigitalOcean.new(options)

      bot.execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchBillingFromDigitalOcean', avoid_process: true },
        process_options: { secret: DIGITAL_OCEAN_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'FetchBillingFromDigitalOcean' }
      }
    end
  end
end
