# frozen_string_literal: true

require_relative '../bots/notify_whatsapp'
require 'bas/shared_storage/postgres'

connection = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

read_options = {
  connection:,
  db_table: 'observed_websites_availability',
  tag: 'ReviewWebsiteResult'
}

write_options = {
  connection:,
  db_table: 'observed_websites_availability',
  tag: 'NotifyWhatsapp'
}

options = {
  connection:
}

shared_storage = Bas::SharedStorage::Postgres.new(read_options: read_options, write_options: write_options)
bot = Implementation::NotifyWhatsapp.new(options, shared_storage)
bot.execute
