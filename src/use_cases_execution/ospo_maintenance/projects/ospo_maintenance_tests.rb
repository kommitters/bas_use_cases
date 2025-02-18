# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_github_issues'
require_relative '../config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'OspoMaintenanceTests',
  where: 'tag=$1 ORDER BY inserted_at DESC',
  params: ['OspoMaintenanceTests']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'OspoMaintenanceTests'
}

options = {
  github_token: ENV['GITHUB_ACCESS_TOKEN'], # Agregamos el token de GitHub (opcional)
  repo: 'kommitters/ospo_maintenance_tests', # Identifica el repo con su nombre
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

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchGithubIssues.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
