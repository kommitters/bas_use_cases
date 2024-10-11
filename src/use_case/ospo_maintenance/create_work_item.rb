# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/create_work_item'

module UseCase
  # CreateWorkItem
  #
  class CreateWorkItem < UseCase::Base
    TABLE = 'github_issues'
    OSPO_MAINTENANCE_NOTION_DATABASE_ID = ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def execute
      bot = Bot::CreateWorkItem.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'CreateWorkItemRequest' },
        process_options: { database_id: OSPO_MAINTENANCE_NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'CreateWorkItem' }
      }
    end
  end
end
