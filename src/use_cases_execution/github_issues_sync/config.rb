# frozen_string_literal: true

# github_issues_sync/config.rb

##
# This file is used to store the configuration of the github_issues_sync use case.
# It contains the connection information to the database where the GitHub issues data is stored.
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

  PRIVATE_PEM = File.read('/app/github_private_key.pem')
  APP_ID = ENV.fetch('OSPO_MAINTENANCE_APP_ID')
  ORGANIZATION = 'kommitters'
  DOMAIN = 'kommit.engineering'
  WORK_ITEM_TYPE = 'activity'

  MAX_RECORDS = 5000
  DEFAULT_STATUS = ENV.fetch('GITHUB_ISSUES_DEFAULT_STATUS', 'BACKLOG')
  DEFAULT_DEADLINE = ENV['GITHUB_ISSUES_DEFAULT_DEADLINE']
  APEX_GITHUB_ISSUES_ENDPOINT = ENV.fetch('APEX_GITHUB_ISSUES_ENDPOINT', 'github/issues')
end
