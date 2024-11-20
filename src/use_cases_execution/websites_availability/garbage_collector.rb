# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/garbage_collector'
require_relative 'config'

# Configuration
write_options = {
  connection: Config::CONNECTION,
  db_table: 'web_availability'
}

options = {
  connection: Config::CONNECTION,
  db_table: 'web_availability'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::GarbageCollector.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
