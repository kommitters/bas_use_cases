# frozen_string_literal: true

# github_notion_issues_sync/config.rb

##
# This file is used to store the configuration of the github_notion_issues_sync use case.
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

  REPO_IDENTIFIER = ENV.fetch('REPO_IDENTIFIER')
  GITHUB_API_TOKEN = ENV.fetch('GITHUB_API_TOKEN')
  NOTION_DATABASE_ID = ENV.fetch('NOTION_DATABASE_ID')
  NOTION_SECRET = ENV.fetch('NOTION_SECRET')
end
