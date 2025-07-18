# frozen_string_literal: true

require 'logger'
require 'json'
require 'bas/shared_storage/elasticsearch'
require 'bas/shared_storage/default'

require_relative '../../implementations/elasticsearch_garbage_collector'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  index: 'birthdays',
  tag: 'GarbageCollector'
}

options = {
  connection: Config::CONNECTION,
  index: 'birthdays'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Elasticsearch.new({ write_options: })

  Implementation::ElasticsearchGarbageCollector.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
