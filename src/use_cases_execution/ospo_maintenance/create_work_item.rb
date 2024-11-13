# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/create_work_item'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'CreateWorkItemRequest'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'CreateWorkItem'
}

options = {
  database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::CreateWorkItem.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
