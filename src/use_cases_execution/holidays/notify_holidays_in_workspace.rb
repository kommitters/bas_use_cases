# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/elasticsearch'

require_relative '../../implementations/notify_workspace'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  index: 'holidays',
  tag: 'FormatHolidays'
}
write_options = {
  connection: Config::CONNECTION,
  index: 'holidays',
  tag: 'NotifyHolidaysWorkspace'
}

options = {
  webhook: ENV.fetch('GOOGLE_CHAT_WEBHOOK_HOLIDAYS')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Elasticsearch.new({ read_options:, write_options: })

  Implementation::NotifyWorkspace.new(options, shared_storage).execute
rescue StandardError => e
  # Logger.new($stdout).info(e.message)
  raise e
end
