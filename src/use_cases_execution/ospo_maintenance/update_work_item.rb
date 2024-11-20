# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/update_work_item'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'UpdateWorkItemRequest'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'github_issues',
  tag: 'UpdateWorkItem'
}

options = {
  users_database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::UpdateWorkItem.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
