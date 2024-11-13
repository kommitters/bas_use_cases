# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_billing_from_digital_ocean'
require_relative 'config'
require 'bas/shared_storage'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'do_billing',
  tag: 'FetchBillingFromDigitalOcean',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchBillingFromDigitalOcean']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'do_billing',
  tag: 'FetchBillingFromDigitalOcean'
}

options = {
  secret: ENV.fetch('DIGITAL_OCEAN_SECRET')
}

# Process bot
begin
  shared_storage = SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::FetchBillingFromDigitalOcean.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
