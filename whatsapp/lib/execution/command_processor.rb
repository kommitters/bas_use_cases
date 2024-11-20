# frozen_string_literal: true

require_relative '../bots/command_processor'
require 'bas/shared_storage/postgres'
require 'dotenv/load'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

read_options = {
  connection:,
  db_table: 'api_data',
  tag: 'FetchFromAPI',
  stage: 'unprocessed'
}

write_options = {
  connection:,
  db_table: 'api_data',
  tag: 'NotifyWhatsapp'
}

options = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

shared_storage = Bas::SharedStorage::Postgres.new(read_options: read_options, write_options: write_options)
bot = Bas::Bot::CommandProcessor.new(options, shared_storage)
bot.execute
