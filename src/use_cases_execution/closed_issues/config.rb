# frozen_string_literal: true

# closed_issues/config.rb

require 'dotenv/load'

module Config
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  NOTION_CLOSED_ISSUES_DATABASE_ID = ENV.fetch('NOTION_CLOSED_ISSUES_DATABASE_ID')

  NOTION_SECRET = ENV.fetch('NOTION_SECRET')
end
