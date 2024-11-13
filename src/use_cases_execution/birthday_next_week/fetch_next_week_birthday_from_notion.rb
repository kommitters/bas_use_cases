# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_next_week_birthday_from_notion'
require_relative 'config'
# Configuration

write_options = {
  connection: Config::CONNECTION,
  db_table: 'birthday',
  tag: 'FetchNextWeekBirthdaysFromNotion'
}

options = {
  database_id: ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage_reader = SharedStorage::Default.new
  shared_storage_writer = SharedStorage::Postgres.new({ write_options: })

  Bot::FetchNextWeekBirthdaysFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
