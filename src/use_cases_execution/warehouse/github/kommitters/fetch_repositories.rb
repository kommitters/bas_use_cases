# frozen_string_literal: true

require 'bas/shared_storage/postgres'
require_relative '../../../../implementations/fetch_repositories_from_github'
require_relative '../../../../../log/bas_logger'
require_relative '../../config'

# 1. Read Options (Standard for Bot Base, though Discovery is mostly stateless)
read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchRepositoriesFromGithubKommitters']
}

# 2. Write Options (Where data is staged for the Ingester)
write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchRepositoriesFromGithubKommitters'
}

github_config = Config::Github.kommiters

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  # Execute the Bot
  Implementation::FetchRepositoriesFromGithub.new(github_config, shared_storage).execute

  BAS_LOGGER.info({
                    invoker: 'FetchRepositoriesFromGithubKommitters',
                    message: 'Process completed successfully from GitHub Kommitters..',
                    context: { action: 'fetch', entity: 'Repositories', org: 'kommitters' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchRepositoriesFromGithubKommitters',
                     message: 'Error during fetching Repositories from GitHub Kommitters..',
                     context: { action: 'fetch', entity: 'Repositories' },
                     error: e.message
                   })
end
