# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/compare_wip_limit_count'
require_relative 'config'

# Configuration
read_options = {
  connection: WipLimitConfig::CONNECTION,
  db_table: 'wip_limits',
  tag: 'FetchDomainsWipLimitFromNotion'
}

write_options = {
  connection: WipLimitConfig::CONNECTION,
  db_table: 'wip_limits',
  tag: 'CompareWipLimitCount'
}

options = {}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::CompareWipLimitCount.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
