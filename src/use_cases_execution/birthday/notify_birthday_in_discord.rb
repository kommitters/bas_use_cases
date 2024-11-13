# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/birthday/notify_birthday_in_discord'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: "birthday",
  tag: "FormatBirthdays"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "birthday",
  tag: "NotifyDiscord"
}

options = {
  name: ENV.fetch('DISCORD_BOT_NAME'),
  webhook: ENV.fetch('BIRTHDAY_DISCORD_WEBHOOK')
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::NotifyDiscord.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
