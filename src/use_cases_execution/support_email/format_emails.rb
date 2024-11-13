# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/format_emails'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: "support_emails",
  tag: "FetchEmailsFromImap"
}

write_options = {
  connection: Config::CONNECTION,
  db_table: "support_emails",
  tag: "FormatEmails"
}

options = {
  template: "The <sender> has requested support the <date>",
  frequency: 5,
  timezone: "-05:00"
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::FormatEmails.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
