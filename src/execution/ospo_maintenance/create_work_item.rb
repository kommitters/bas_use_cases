# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/ospo_maintenance/create_work_item'

# Configuration
params = {
  database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET'),
  table_name: ENV.fetch('OSPO_MAINTENANCE_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Create::WorkItem.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
