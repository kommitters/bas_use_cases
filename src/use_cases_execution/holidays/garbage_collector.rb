# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/elasticsearch'

require_relative 'config'
require_relative '../../implementations/elasticsearch_garbage_collector'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  index: 'holidays',
  tag: 'GarbageCollector'
}

options = {
  connection: Config::CONNECTION,
  index: 'holidays'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Elasticsearch.new({ write_options: })

  Implementation::ElasticsearchGarbageCollector.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  # Logger.new($stdout).info(e.message)
  raise e
end
