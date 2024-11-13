# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/pto/notify_pto_in_discord'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: "pto",
  tag: "HumanizePto"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "pto",
  tag: "NotifyDiscord"
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('PTO_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
