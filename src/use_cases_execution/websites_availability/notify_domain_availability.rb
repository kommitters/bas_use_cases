# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/websites_availability/notify_domain_availability'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: "web_availability",
  tag: "ReviewDomainAvailability"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "web_availability",
  tag: "NotifyDiscord"
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('WEBSITES_AVAILABILITY_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::NotifyDiscord.new(options, shared_storage).execute 
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
