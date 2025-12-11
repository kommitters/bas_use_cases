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
  params: [false, 'FetchPullRequestsFromGithubKommitters']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchPullRequestsFromGithubKommitters'
}

github_config = Config::Github.kommiters.merge(
  db_connection: Config::Database::WAREHOUSE_CONNECTION
)

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchPullRequestsFromGithub.new(github_config, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchPullRequestsFromGithubKommitters',
                    message: 'Process completed successfully from Kommitters.',
                    context: { action: 'fetch', entity: 'PullRequests' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchPullRequestsFromGithubKommitters',
                     message: 'Error during fetching Pull Requests from GitHub Kommitters.',
                     context: { action: 'fetch', entity: 'PullRequests' },
                     error: e.message
                   })
end
