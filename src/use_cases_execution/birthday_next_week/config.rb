# frozen_string_literal: true

##
# This file is used to store the configuration of the birthday_next_week use case.
# It contains the connection information to the database where the birthday_next_week data is stored.
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
end
