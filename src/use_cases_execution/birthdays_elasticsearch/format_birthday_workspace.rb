# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/elasticsearch'

require_relative '../../implementations/format_birthday'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  index: 'birthdays',
  tag: 'FetchBirthdaysFromNotionForWorkspace'
}

write_options = {
  connection: Config::CONNECTION,
  index: 'birthdays',
  tag: 'FormatBirthdaysWorkspace'
}

options = {
  template: '<name> Wishing you a very happy birthday! Enjoy your special day! 🎂 🎁 '
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Elasticsearch.new({ read_options:, write_options: })

  Implementation::FormatBirthdays.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
