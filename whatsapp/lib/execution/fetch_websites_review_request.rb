# frozen_string_literal: true

require_relative '../bots/fetch_websites_review_request'
require_relative 'config'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

write_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'FetchWebsiteReviewRequest'
}

options = {
  connection: Config::CONNECTION
}

shared_storage_reader = Bas::SharedStorage::Default.new
shared_storage_writter = Bas::SharedStorage::Postgres.new(write_options: write_options)
bot = Implementation::FetchWebsiteReviewRequest.new(options, shared_storage_reader, shared_storage_writter)
bot.execute
