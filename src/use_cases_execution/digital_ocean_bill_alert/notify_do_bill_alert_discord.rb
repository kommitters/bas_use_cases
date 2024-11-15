# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/notify_discord'
require_relative 'config'
require 'bas/shared_storage/postgres'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'do_billing',
  tag: 'FormatDoBillAlert'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'do_billing',
  tag: 'NotifyDiscord'
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('DIGITAL_OCEAN_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
