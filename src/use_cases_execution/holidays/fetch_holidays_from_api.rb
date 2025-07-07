# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/elasticsearch'

require_relative '../../implementations/fetch_holidays'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  index: 'holidays',
  tag: 'FetchHolidaysFromApi'
}

options = {
  year: Time.now.year - 1, # HolidaysAPI requires premium tier to fetch holidays for the current year
  month: Time.now.month,
  day: Time.now.day,
  country: 'CO'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Elasticsearch.new({ write_options: })

  Implementation::FetchHolidays.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
