# frozen_string_literal: true

##
# This file is used to store the configuration of the apollo sync use case.
# It contains the connection information to the database where the apollo data is stored.
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

  PROJECTS_NOTION_DATABASE_ID = ENV.fetch('PROJECTS_NOTION_DATABASE_ID')
  ACTIVITIES_NOTION_DATABASE_ID = ENV.fetch('ACTIVITIES_NOTION_DATABASE_ID')
  WORK_ITEMS_NOTION_DATABASE_ID = ENV.fetch('WORK_ITEMS_NOTION_DATABASE_ID')
  NOTION_SECRET = ENV.fetch('NOTION_SECRET')
end
