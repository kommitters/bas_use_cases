# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/elasticsearch'

require_relative '../../implementations/format_holidays'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  index: 'holidays',
  tag: 'FetchHolidaysFromApi'
}

write_options = {
  connection: Config::CONNECTION,
  index: 'holidays',
  tag: 'FormatHolidays'
}

options = {
  title: '📆 We have some upcoming holidays:'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Elasticsearch.new({ read_options:, write_options: })

  Implementation::FormatHolidays.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
