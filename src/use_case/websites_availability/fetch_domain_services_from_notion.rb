# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_domain_services_from_notion'

module UseCase
  # FetchDomainServicesFromNotion
  #
  class FetchDomainServicesFromNotion < UseCase::Base
    TABLE = 'web_availability'

    def execute
      bot = Bot::FetchDomainServicesFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'FetchDomainServicesFromNotion' }
      }
    end

    def database_id
      ENV.fetch('WEBSITES_AVAILABILITY_NOTION_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
