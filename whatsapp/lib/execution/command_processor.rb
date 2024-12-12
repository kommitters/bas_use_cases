# frozen_string_literal: true

require_relative '../bots/command_processor'
require_relative 'config'
require 'bas/shared_storage/postgres'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'WhatsappWebhook'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'observed_websites_availability',
  tag: 'CommandProcessor'
}

options = {
  connection: Config::CONNECTION,
  avoid_empty_data: true
}

shared_storage = Bas::SharedStorage::Postgres.new(read_options: read_options, write_options: write_options)
bot = Implementation::CommandProcessor.new(options, shared_storage)
bot.execute
