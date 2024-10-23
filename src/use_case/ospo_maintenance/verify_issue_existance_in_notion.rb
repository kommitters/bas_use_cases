# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/verify_issue_existance_in_notion'

module UseCase
  # VerifyIssueExistanceInNotion
  #
  class VerifyIssueExistanceInNotion < UseCase::Base
    TABLE = 'github_issues'

    def execute
      bot = Bot::VerifyIssueExistanceInNotion.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'GithubIssueRequest' },
        process_options: { database_id:, secret: },
        write_options: { connection:, db_table: TABLE, tag: 'VerifyIssueExistanceInNotio' }
      }
    end

    def database_id
      ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID')
    end

    def secret
      ENV.fetch('NOTION_SECRET')
    end
  end
end
