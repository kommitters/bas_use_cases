# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/notify_discord_dm'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'missing_work_logs',
  tag: 'FetchPeopleWithMissingLogs'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'missing_work_logs',
  tag: 'NotifyDiscordDm'
}

options = {
  token: Config::DISCORD_BOT_TOKEN
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyDiscordDm.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
