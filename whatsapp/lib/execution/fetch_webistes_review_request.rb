# frozen_string_literal: true

require_relative '../bots/fetch_webistes_review_request'
require 'bas/shared_storage/postgres'
require 'dotenv/load'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

write_options = {
  connection:,
  db_table: 'observed_websites_availability',
  tag: 'FetchWebsiteReviewRequest'
}

options = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

shared_storage = Bas::SharedStorage::Postgres.new(write_options: write_options)
bot = Bas::Bot::FetchWebsiteReviewRequest.new(options, shared_storage)
bot.execute
