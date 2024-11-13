# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/format_birthday'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'birthday',
  tag: 'FetchNextWeekBirthdaysFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'birthday',
  tag: 'FormatNextWeekBirthdays'
}

options = {
  template: 'The Birthday of <name> is today! (<birthday_date>) :birthday: :gift:'
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::FormatBirthdays.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
