# frozen_string_literal: true

require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../config'
require_relative '../../../../log/bas_logger'
require_relative '../../../implementations/fetch_pull_requests_from_github'

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

github_config = Config::Github.kommiters

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
                     message: 'Error during fetching PullRequests from GitHub Kommitters.',
                     context: { action: 'fetch', entity: 'PullRequests' },
                     error: e.message
                   })
end
