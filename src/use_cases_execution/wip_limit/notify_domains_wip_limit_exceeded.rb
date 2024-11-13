# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/wip_limit/notify_domains_wip_limit_exceeded'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: "wip_limits",
  tag: "FormatWipLimitExceeded"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "wip_limits",
  tag: "NotifyDiscord"
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('WIP_LIMIT_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
