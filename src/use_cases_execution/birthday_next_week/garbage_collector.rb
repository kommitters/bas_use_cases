# frozen_string_literal: true

require 'logger'
require 'json'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../implementations/garbage_collector'
require_relative 'config'

# Configuration
write_options = {
  connection: BirthdayNextWeekConfig::CONNECTION,
  db_table: 'birthday',
  tag: 'GarbageCollector'
}

options = {
  connection: BirthdayNextWeekConfig::CONNECTION,
  db_table: 'birthday'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::GarbageCollector.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
