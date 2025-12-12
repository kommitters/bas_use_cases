# frozen_string_literal: true

require 'bas/shared_storage/postgres'

require_relative '../../../../implementations/fetch_pull_requests_from_github'
require_relative '../../../../../log/bas_logger'
require_relative '../../config'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchPullRequestsFromGithubKommitCo']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchPullRequestsFromGithubKommitCo'
}

github_config = Config::Github.kommit_co.merge(
  db_connection: Config::Database::WAREHOUSE_CONNECTION
)

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchPullRequestsFromGithub.new(github_config, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchPullRequestsFromGithubKommitCo',
                    message: 'Process completed successfully from Kommit-Co.',
                    context: { action: 'fetch', entity: 'PullRequests' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchPullRequestsFromGithubKommitCo',
                     message: 'Error during fetching Pull Requests from GitHub Kommit-Co.',
                     context: { action: 'fetch', entity: 'PullRequests' },
                     error: e.message,
                     backtrace: e.backtrace&.first(20)
                   })
end
