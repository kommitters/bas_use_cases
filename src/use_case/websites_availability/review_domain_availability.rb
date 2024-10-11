# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/review_domain_availability'

module UseCase
  # ReviewDomainAvailability
  #
  class ReviewDomainAvailability < UseCase::Base
    TABLE = 'web_availability'

    def execute
      bot = Bot::ReviewDomainAvailability.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: @table_name, tag: 'ReviewDomainRequest' },
        write_options: { connection:, db_table: @table_name, tag: 'ReviewDomainAvailability' }
      }
    end
  end
end
