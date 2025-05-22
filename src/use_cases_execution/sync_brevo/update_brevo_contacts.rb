# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/update_brevo_contacts'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'FetchNetworksFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'apollo_sync',
  tag: 'UpdateBrevoContacts'
}

options = {
  brevo_token: Config::BREVO_TOKEN,
  brevo_list_id: Config::BREVO_LIST_ID
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::UpdateBrevoContacts.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
