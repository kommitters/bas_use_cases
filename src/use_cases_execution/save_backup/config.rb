# frozen_string_literal: true

##
# This file is used to store the configuration of the save_backup use case.
# It contains the connection information to the database where the backup history is stored,
# as well as the configuration for the R2 bucket. The connection information is stored in
# the CONNECTION constant, and the R2 config in the R2_CONFIG constant.
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

  R2_CONFIG = {
    access_key_id: ENV.fetch('R2_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('R2_SECRET_ACCESS_KEY'),
    endpoint: ENV.fetch('R2_ENDPOINT'),
    region: ENV.fetch('R2_REGION'),
    bucket_name: ENV.fetch('R2_BUCKET_NAME')
  }.freeze
end
