# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/notify_discord'
require_relative 'config'

# Configuration
read_options = {
  connection: WebsitesAvailabilityConfig::CONNECTION,
  db_table: 'web_availability',
  tag: 'ReviewDomainAvailability'
}

write_options = {
  connection: WebsitesAvailabilityConfig::CONNECTION,
  db_table: 'web_availability',
  tag: 'NotifyDiscord'
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('WEBSITES_AVAILABILITY_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
