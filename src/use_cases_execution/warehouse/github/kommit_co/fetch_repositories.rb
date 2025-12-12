# frozen_string_literal: true

require 'bas/shared_storage/postgres'
require_relative '../../../../implementations/warehouse/github/fetch_repositories_from_github'
require_relative '../../../../../log/bas_logger'
require_relative '../../config'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchRepositoriesFromGithubKommitCo']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchRepositoriesFromGithubKommitCo'
}

github_config = Config::Github.kommiters

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchRepositoriesFromGithub.new(github_config, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchRepositoriesFromGithubKommitCo',
                    message: 'Process completed successfully from Kommit Co.',
                    context: { action: 'fetch', entity: 'Repositories', org: 'Kommit-Co' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchRepositoriesFromGithubKommitCo',
                     message: 'Error during fetching Repositories from Kommit-Co.',
                     context: { action: 'fetch', entity: 'Repositories' },
                     error: e.message,
                     backtrace: e.backtrace&.first(20)
                   })
end
