# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/notify_workspace'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'support_emails',
  tag: 'FormatEmails'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'support_emails',
  tag: 'NotifyWorkspace'
}

options = {
  webhook: ENV.fetch('SUPPORT_EMAIL_WORKSPACE_WEBHOOK')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::NotifyWorkspace.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
