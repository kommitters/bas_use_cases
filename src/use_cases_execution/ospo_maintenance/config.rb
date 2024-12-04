# frozen_string_literal: true

##
# This file is used to store the configuration of the ospo_maintenance use case.
# It contains the connection information to the database where the ospo_maintenance data is stored.
# The connection information is stored in the CONNECTION constant.
#

require 'dotenv/load'

module Config
  # PRIVATE_PEM = File.read('/app/github_private_key.pem')
  APP_ID = ENV.fetch('OSPO_MAINTENANCE_APP_ID')
  ORGANIZATION = 'kommitters'
  DOMAIN = 'kommit.engineering'
  WORK_ITEM_TYPE = 'activity'

  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze
end
