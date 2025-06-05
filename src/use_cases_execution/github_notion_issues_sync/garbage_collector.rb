# frozen_string_literal: true

require 'logger'
require 'bas/bot/base'
require 'bas/shared_storage/postgres'
require_relative '../../implementations/github_notion_sync_garbage_collector'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync'
}

options = {
  connection: Config::CONNECTION,
  db_table: 'github_notion_issues_sync'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ write_options: })

  # Archive processed GitHub issues records
  Implementation::GithubNotionSyncGarbageCollector.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end