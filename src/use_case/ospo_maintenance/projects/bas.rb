# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_github_issues'

module UseCase
  # CreateWorkItem
  #
  class Bas < UseCase::Base
    TABLE = 'github_issues'

    def execute
      bot = Bot::FetchGithubIssues.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'BasGithubIssues' },
        process_options:,
        write_options: { connection:, db_table: TABLE, tag: 'BasGithubIssues' }
      }
    end

    def process_options # rubocop:disable Metrics/MethodLength
      {
        private_pem: File.read('/app/github_private_key.pem'),
        app_id: ENV.fetch('OSPO_MAINTENANCE_APP_ID'),
        repo: 'kommitters/bas',
        filters: { state: 'all' },
        organization: 'kommitters',
        domain: 'kommit.engineering',
        work_item_type: 'activity',
        type_id: '2b29cbb1e76c4c3ea3692e55fd5ceb4d',
        connection:,
        db_table: TABLE,
        tag: 'GithubIssueRequest'
      }
    end
  end
end
