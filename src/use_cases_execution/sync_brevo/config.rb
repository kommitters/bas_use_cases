# frozen_string_literal: true

##
# This file is used to store the configuration of the sync brevo use case.
# It contains the connection information to the database.
# The connection information is stored in the CONNECTION constant.
#

require 'dotenv/load'

module Config
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  NETWORK_NOTION_DATABASE_ID = ENV.fetch('NETWORK_NOTION_DATABASE_ID')
  NOTION_SECRET = ENV.fetch('NOTION_SECRET')
  BREVO_TOKEN = ENV.fetch('BREVO_TOKEN')
  BREVO_LIST_ID = ENV.fetch('BREVO_LIST_ID')
end
