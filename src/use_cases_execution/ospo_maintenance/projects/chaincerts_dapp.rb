# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_github_issues'
require_relative '../config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'ChaincertsDAppGithubIssues',
  where: 'tag=$1 ORDER BY inserted_at DESC',
  params: ['ChaincertsDAppGithubIssues']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'ChaincertsDAppGithubIssues'
}

options = {
  private_pem: Config::PRIVATE_PEM,
  app_id: Config::APP_ID,
  repo: 'kommitters/chaincerts-dapp',
  filters: { state: 'open' },
  organization: Config::ORGANIZATION,
  domain: Config::DOMAIN,
  status: 'Backlog',
  work_item_type: Config::WORK_ITEM_TYPE,
  type_id: '97518e360a514a32922aaddb553d742b',
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchGithubIssues.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
