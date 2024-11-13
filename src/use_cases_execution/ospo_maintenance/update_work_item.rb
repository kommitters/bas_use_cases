# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/update_work_item'

# Configuration
params = {
  users_database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET'),
  table_name: 'github_issues',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}
options = {
  read_options: {
    connection: {
      host: ENV.fetch('DB_HOST'),
      port: ENV.fetch('DB_PORT'),
      dbname: ENV.fetch('POSTGRES_DB'),
      user: ENV.fetch('POSTGRES_USER'),
      password: ENV.fetch('POSTGRES_PASSWORD')
    },
    db_table: "github_issues",
    tag: "UpdateWorkItemRequest"
  },
  process_options: {
    secret: ENV.fetch('NOTION_SECRET'),
  },
  write_options: {
    connection: {
      host: ENV.fetch('DB_HOST'),
      port: ENV.fetch('DB_PORT'),
      dbname: ENV.fetch('POSTGRES_DB'),
      user: ENV.fetch('POSTGRES_USER'),
      password: ENV.fetch('POSTGRES_PASSWORD')
    },
    db_table: "github_issues",
    tag: "UpdateWorkItem"
  }
}

# Process bot
begin
  bot = Bot::UpdateWorkItem.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
