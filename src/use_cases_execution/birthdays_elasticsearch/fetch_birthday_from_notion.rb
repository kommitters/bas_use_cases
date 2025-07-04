# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/elasticsearch'

require_relative '../../implementations/fetch_birthday_from_notion'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  index: 'birthdays',
  tag: 'FetchBirthdaysFromNotionForWorkspace'
}

options = {
  database_id: ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Elasticsearch.new({ write_options: })

  Implementation::FetchBirthdaysFromNotion.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  # Logger.new($stdout).info(e.message)
  raise e
end
