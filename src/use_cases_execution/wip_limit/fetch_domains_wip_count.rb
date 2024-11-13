# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/wip_limit/fetch_domains_wip_count'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: "wip_limits",
  tag: "FetchDomainsWipCountsFromNotion"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "wip_limits",
  tag: "FetchDomainsWipLimitFromNotion"
}

options = {
  database_id: ENV.fetch('WIP_COUNT_NOTION_DATABASE_ID'),
  secret: ENV.fetch('NOTION_SECRET'),
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::FetchDomainsWipLimitFromNotion.new(options, shared_storage).execute  
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
