# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/notify_workspace'
require_relative 'config'
require 'bas/shared_storage/postgres'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'FormatWipLimitExceeded'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'wip_limits',
  tag: 'NotifyWorkspace'
}

options = {
  webhook: ENV.fetch('WIP_LIMIT_WORKSPACE_WEBHOOK')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyWorkspace.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
