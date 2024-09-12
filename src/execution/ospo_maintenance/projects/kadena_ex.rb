# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/ospo_maintenance/fetch_github_issues'

# Configuration
params = {
  tag: 'KadenaExGithubIssues',
  repo: 'kommitters/kadena.ex',
  organization: 'kommitters',
  domain: 'kommit.engineering',
  work_item_type: 'activity',
  type_id: 'ecc3b2bcc3c941d29e3499721c063dd6',
  private_pem: ENV.fetch('OSPO_MAINTENANCE_SECRET'),
  app_id: ENV.fetch('OSPO_MAINTENANCE_APP_ID'),
  table_name: 'github_issues',
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
