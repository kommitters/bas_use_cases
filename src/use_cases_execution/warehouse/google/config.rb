# frozen_string_literal: true

##
# This file is used to store the configuration of the warehouse sync data.
# It contains the connection information to the database where the warehouse sync data is stored.
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

  WAREHOUSE_CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('WAREHOUSE_POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze
end
