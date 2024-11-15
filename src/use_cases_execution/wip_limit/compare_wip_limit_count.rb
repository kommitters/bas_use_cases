# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/compare_wip_limit_count'
require_relative 'config'
require 'bas/shared_storage/postgres'
# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'FetchDomainsWipLimitFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'CompareWipLimitCount'
}

options = {}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::CompareWipLimitCount.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
