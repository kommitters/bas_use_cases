# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_do_bill_alert'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'do_billing',
  tag: 'FetchBillingFromDigitalOcean',
  where: 'tag=$1 ORDER BY archived ASC, inserted_at DESC',
  params: ['FetchBillingFromDigitalOcean']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'do_billing',
  tag: 'FormatDoBillAlert'
}

options = {
  threshold: ENV.fetch('DIGITAL_OCEAN_THRESHOLD').to_f
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FormatDoBillAlert.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
