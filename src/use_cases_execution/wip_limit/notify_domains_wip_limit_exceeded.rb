# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/notify_discord'
require_relative 'config'
require 'bas/shared_storage/postgres'

# Configuration
read_options = {
  connection: WipLimitConfig::CONNECTION,
  db_table: 'wip_limits',
  tag: 'FormatWipLimitExceeded'
}

write_options = {
  connection: WipLimitConfig::CONNECTION,
  db_table: 'wip_limits',
  tag: 'NotifyDiscord'
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('WIP_LIMIT_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
