# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_birthday'
require_relative 'config'

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
  template: 'The Birthday of <name> will be next week! (<birthday_date>) :birthday: :gift:'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FormatBirthdays.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
