# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/verify_issue_existance_in_notion'

module UseCase
  # VerifyIssueExistanceInNotion
  #
  class VerifyIssueExistanceInNotion < UseCase::Base
    TABLE = 'github_issues'
    OSPO_MAINTENANCE_NOTION_DATABASE_ID = ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID')
    NOTION_SECRET = ENV.fetch('NOTION_SECRET')

    def execute
      bot = Bot::VerifyIssueExistanceInNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'GithubIssueRequest' },
        process_options: { database_id: OSPO_MAINTENANCE_NOTION_DATABASE_ID, secret: NOTION_SECRET },
        write_options: { connection:, db_table: TABLE, tag: 'VerifyIssueExistanceInNotio' }
      }
    end
  end
end
