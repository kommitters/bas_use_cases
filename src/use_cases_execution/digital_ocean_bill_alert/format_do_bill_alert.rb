# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_do_bill_alert'
require_relative 'config'

# Configuration
read_options = {
  connection: DigitalOceanBillAlertConfig::CONNECTION,
  db_table: 'do_billing',
  tag: 'FetchBillingFromDigitalOcean'
}

write_options = {
  connection: DigitalOceanBillAlertConfig::CONNECTION,
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
