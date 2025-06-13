# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/notify_workspace'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'birthday',
  tag: 'FormatNextWeekBirthdaysWorkspace'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'birthday',
  tag: 'NotifyWorkspace'
}

options = {
  webhook: ENV.fetch('GOOGLE_CHAT_WEBHOOK_BIRTHDAY_ADMIN')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyWorkspace.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
