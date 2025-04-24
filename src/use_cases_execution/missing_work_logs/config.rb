# frozen_string_literal: true

##
# This file is used to store the configuration of the missing work logs use case.
# It contains the connection information to the database where the missing work logs data is stored.
# and the credentials to access the work logs API.
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

  WORK_LOGS_URL = ENV.fetch('WORK_LOGS_URL')
  WORK_LOGS_API_SECRET = ENV.fetch('WORK_LOGS_API_SECRET')

  ADMIN_DM_ID = ENV.fetch('ADMIN_DM_ID')
  OPS_DM_ID = ENV.fetch('OPS_DM_ID')
  ENGINEERING_DM_ID = ENV.fetch('ENGINEERING_DM_ID')
  BIZDEV_DM_ID = ENV.fetch('BIZDEV_DM_ID')

  DISCORD_BOT_TOKEN = ENV.fetch('DISCORD_BOT_TOKEN')
end
