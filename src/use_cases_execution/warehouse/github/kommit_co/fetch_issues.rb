# frozen_string_literal: true

require 'bas/shared_storage/postgres'

require_relative '../../../../implementations/fetch_issues_from_github'
require_relative '../../../../../log/bas_logger'
require_relative '../../config'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchIssuesFromGithubKommitCo']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchIssuesFromGithubKommitCo'
}

github_config = Config::Github.kommit_co.merge(
  db_connection: Config::Database::WAREHOUSE_CONNECTION
)

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchIssuesFromGithub.new(github_config, shared_storage).execute
  BAS_LOGGER.info({
                    invoker: 'FetchIssuesFromGithubKommitCo',
                    message: 'Process completed successfully from Kommit Co.',
                    context: { action: 'fetch', entity: 'Issues' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchIssuesFromGithubKommitCo',
                     message: 'Error during fetching Issues from GitHub Kommit Co.',
                     context: { action: 'fetch', entity: 'Issues' },
                     error: e.message
                   })
end
