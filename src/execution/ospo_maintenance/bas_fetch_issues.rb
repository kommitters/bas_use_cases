# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/ospo_maintenance/fetch_github_issues'

# Configuration
params = {
  tag: "BasGithubIssues",
  repo: "kommitters/bas",
  organization: "kommitters",
  domain: "kommit.engineering",
  work_item_type: "activity",
  type_id: "2b29cbb1e76c4c3ea3692e55fd5ceb4d",
  private_pem: ENV.fetch('OSPO_MAINTENANCE_SECRET'),
  app_id: ENV.fetch('OSPO_MAINTENANCE_APP_ID'),
  table_name: ENV.fetch('OSPO_MAINTENANCE_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Fetch::GithubIssues.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
