# frozen_string_literal: true

require_relative '../bots/notify_whatsapp'
require_relative 'config'
require 'bas/shared_storage/postgres'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'ReviewWebsiteResult'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'NotifyWhatsapp'
}

options = {
  connection: Config::CONNECTION,
  avoid_empty_data: true
}

shared_storage = Bas::SharedStorage::Postgres.new(read_options: read_options, write_options: write_options)
bot = Implementation::NotifyWhatsapp.new(options, shared_storage)
bot.execute
