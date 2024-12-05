# frozen_string_literal: true

require_relative '../bots/review_website_availability'
require_relative 'config'
require 'bas/shared_storage/postgres'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'FetchWebsiteReviewRequest'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'ReviewWebsiteAvailability'
}

options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'ReviewWebsiteResult'
}

shared_storage = Bas::SharedStorage::Postgres.new(read_options: read_options, write_options: write_options)
bot = Implementation::ReviewWebsiteAvailability.new(options, shared_storage)
bot.execute
