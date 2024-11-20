# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/review_domain_availability'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'web_availability',
  tag: 'FetchDomainServicesFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'web_availability',
  tag: 'ReviewWebsiteAvailability'
}

options = {
  connection: Config::CONNECTION,
  db_table: 'web_availability',
  tag: 'ReviewDomainAvailability'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::ReviewDomainAvailability.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
