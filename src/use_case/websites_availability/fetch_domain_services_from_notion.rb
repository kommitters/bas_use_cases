# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_domain_services_from_notion'

module UseCase
  # FetchDomainServicesFromNotion
  #
  class FetchDomainServicesFromNotion < UseCase::Base
    TABLE = 'web_availability'
    WEBSITES_AVAILABILITY_NOTION_DATABASE_ID = ENV.fetch('WEBSITES_AVAILABILITY_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def execute
      bot = Bot::FetchDomainServicesFromNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        process_options: { database_id: WEBSITES_AVAILABILITY_NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'FetchDomainServicesFromNotion' }
      }
    end
  end
end
