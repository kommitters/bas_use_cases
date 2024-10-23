# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/update_work_item'

module UseCase
  # UpdateWorkItem
  #
  class UpdateWorkItem < UseCase::Base
    TABLE = 'github_issues'

    def execute
      bot = Bot::UpdateWorkItem.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'UpdateWorkItemRequest' },
        process_options: { users_database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'UpdateWorkItem' }
      }
    end

    def users_database_id
      ENV.fetch('OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
