# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/update_work_item'

module UseCase
  # UpdateWorkItem
  #
  class UpdateWorkItem < UseCase::Base
    TABLE = 'github_issues'
    OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID = ENV.fetch('OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def perform
      bot = Bot::UpdateWorkItem.new(options)

      bot.execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'UpdateWorkItemRequest' },
        process_options: { users_database_id: OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'UpdateWorkItem' }
      }
    end
  end
end
