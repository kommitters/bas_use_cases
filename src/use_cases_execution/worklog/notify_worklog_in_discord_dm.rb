# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/notify_worklog_in_discord_dm'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'worklog',
  tag: 'FormatWorklogs'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'worklog',
  tag: 'NotifyWorklogInDiscordDm'
}

options = {
  token: ENV.fetch('DISCORD_BOT_TOKEN'),
  discord_user_id: ENV.fetch('DISCORD_USER_ID')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyWorklogInDiscordDm.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
