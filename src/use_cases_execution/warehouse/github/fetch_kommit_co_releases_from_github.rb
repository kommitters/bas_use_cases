# frozen_string_literal: true

require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../config'
require_relative '../../../../log/bas_logger'
require_relative '../../../implementations/fetch_releases_from_github'

read_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchReleasesFromGithub']
}

write_options = {
  connection: Config::Database::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchReleasesFromGithub'
}

github_config = Config::Github.kommit_co

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchReleasesFromGithub.new(github_config, shared_storage).execute
  BAS_LOGGER.info({
                    invoker: 'FetchReleasesFromGithub',
                    message: 'Process completed successfully from Kommit Co.',
                    context: { action: 'fetch', entity: 'Releases' }
                  })
rescue StandardError => e
  BAS_LOGGER.error({
                     invoker: 'FetchReleasesFromGithub',
                     message: 'Error during fetching Releases from GitHub Kommit Co.',
                     context: { action: 'fetch', entity: 'Releases' },
                     error: e.message
                   })
end
