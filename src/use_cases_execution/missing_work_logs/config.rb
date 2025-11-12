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
  MISSING_WORK_LOGS_ADMIN_WORKSPACE_WEBHOOK = ENV.fetch('MISSING_WORK_LOGS_ADMIN_WORKSPACE_WEBHOOK')
  MISSING_WORK_LOGS_OPS_WORKSPACE_WEBHOOK = ENV.fetch('MISSING_WORK_LOGS_OPS_WORKSPACE_WEBHOOK')
  MISSING_WORK_LOGS_ENGINEERING_WORKSPACE_WEBHOOK = ENV.fetch('MISSING_WORK_LOGS_ENGINEERING_WORKSPACE_WEBHOOK')
  MISSING_WORK_LOGS_BIZDEV_WORKSPACE_WEBHOOK = ENV.fetch('MISSING_WORK_LOGS_BIZDEV_WORKSPACE_WEBHOOK')

end
