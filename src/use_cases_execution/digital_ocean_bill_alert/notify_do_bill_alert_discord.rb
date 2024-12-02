# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/notify_discord'
require_relative 'config'

# Configuration
read_options = {
  connection: DigitalOceanBillAlertConfig::CONNECTION,
  db_table: 'do_billing',
  tag: 'FormatDoBillAlert'
}

write_options = {
  connection: DigitalOceanBillAlertConfig::CONNECTION,
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

  Implementation::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
