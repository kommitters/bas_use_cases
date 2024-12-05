# frozen_string_literal: true

##
# This file is used to store the configuration of the support_email use case.
# It contains the connection information to the database where the support_email data is stored.
# The connection information is stored in the CONNECTION constant.
#

require 'dotenv/load'

module Config
  REFRESH_TOKEN = ENV.fetch('SUPPORT_EMAIL_REFRESH_TOKEN')
  CLIENT_ID = ENV.fetch('SUPPORT_EMAIL_CLIENT_ID')
  CLIENT_SECRET = ENV.fetch('SUPPORT_EMAIL_CLIENT_SECRET')
  TOKEN_URI = 'https://oauth2.googleapis.com/token'

  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze
end
