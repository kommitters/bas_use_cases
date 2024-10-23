# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_github_issues'

module UseCase
  # CreateWorkItem
  #
  class ChaincertsSmartContracts < UseCase::Base
    TABLE = 'github_issues'

    def execute
      bot = Bot::FetchGithubIssues.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'ChaincertsSmartContractsGithubIssues' },
        process_options:,
        write_options: { connection:, db_table: TABLE, tag: 'ChaincertsSmartContractsGithubIssues' }
      }
    end

    def process_options # rubocop:disable Metrics/MethodLength
      {
        private_pem: File.read('/app/github_private_key.pem'),
        app_id: ENV.fetch('OSPO_MAINTENANCE_APP_ID'),
        repo: 'kommitters/chaincerts-smart-contracts',
        filters: { state: 'all' },
        organization: 'kommitters',
        domain: 'kommit.engineering',
        work_item_type: 'activity',
        type_id: 'ecc3b2bcc3c941d29e3499721c063dd6',
        connection:,
        db_table: TABLE,
        tag: 'GithubIssueRequest'
      }
    end
  end
end
