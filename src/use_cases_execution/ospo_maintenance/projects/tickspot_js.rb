# frozen_string_literal: true

require 'logger'

require_relative '../../../implementations/fetch_github_issues'
require_relative '../config'
require 'bas/shared_storage'

repo_tag = 'TickspotJsGithubIssues'
# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: repo_tag,
  where: 'tag=$1 ORDER BY inserted_at DESC',
  params: [repo_tag]
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: repo_tag
}

options = {
  private_pem: Config::PRIVATE_PEM,
  app_id: Config::APP_ID,
  repo: 'kommitters/tickspot.js',
  filters: { state: 'all' },
  organization: Config::ORGANIZATION,
  domain: Config::DOMAIN,
  status: 'Backlog',
  work_item_type: Config::WORK_ITEM_TYPE,
  type_id: 'ecc3b2bcc3c941d29e3499721c063dd6',
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'GithubIssueRequest'
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::FetchGithubIssues.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
