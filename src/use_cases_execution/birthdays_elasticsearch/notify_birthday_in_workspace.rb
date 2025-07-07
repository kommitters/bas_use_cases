# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/elasticsearch'

require_relative '../../implementations/notify_workspace'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  index: 'birthdays',
  tag: 'FormatBirthdaysWorkspace'
}
write_options = {
  connection: Config::CONNECTION,
  index: 'birthdays',
  tag: 'NotifyWorkspace'
}

options = {
  webhook: ENV.fetch('GOOGLE_CHAT_WEBHOOK_BIRTHDAY')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Elasticsearch.new({ read_options:, write_options: })

  Implementation::NotifyWorkspace.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
