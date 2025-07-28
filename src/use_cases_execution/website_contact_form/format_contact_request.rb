# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_contact_request'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'website_form_contact',
  tag: 'WebsiteContactForm'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'website_form_contact',
  tag: 'FormatWebsiteContactForm'
}

options = {
  contact_template: "<name> (<email>)\n   <thematics>",
  verification_template: "Assisted Verification Requested\n " \
                      "Organization Name: <org_name>\n " \
                      "Email: <email>\n " \
                      'Certificate URL: <certificate_url>'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Postgres.new(read_options:)
  shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options:)

  Implementation::FormatContactRequest.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
