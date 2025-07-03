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

  PROJECTS_NOTION_DATABASE_ID = ENV.fetch('PROJECTS_NOTION_DATABASE_ID')
  ACTIVITIES_NOTION_DATABASE_ID = ENV.fetch('ACTIVITIES_NOTION_DATABASE_ID')
  WORK_ITEMS_NOTION_DATABASE_ID = ENV.fetch('WORK_ITEMS_NOTION_DATABASE_ID')
  DOMAINS_NOTION_DATABASE_ID = ENV.fetch('DOMAINS_NOTION_DATABASE_ID')
  DOCUMENTS_NOTION_DATABASE_ID = ENV.fetch('DOCUMENTS_NOTION_DATABASE_ID')
  WEEKLY_SCOPES_NOTION_DATABASE_ID = ENV.fetch('WEEKLY_SCOPES_NOTION_DATABASE_ID')
  PERSONS_NOTION_DATABASE_ID = ENV.fetch('PERSONS_NOTION_DATABASE_ID')
  KEY_RESULTS_NOTION_DATABASE_ID = ENV.fetch('KEY_RESULTS_NOTION_DATABASE_ID')
  HIRED_PERSONS_NOTION_DATABASE_ID = ENV.fetch('HIRED_PERSONS_NOTION_DATABASE_ID')
  NOTION_SECRET = ENV.fetch('NOTION_SECRET')
end
