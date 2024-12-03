# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_wip_limit_exceeded'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'CompareWipLimitCount'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'FormatWipLimitExceeded'
}

options = {
  template: ':warning: The <domain> WIP limit was exceeded by <exceeded>'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FormatWipLimitExceeded.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
