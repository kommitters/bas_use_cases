# frozen_string_literal: true

# closed_issues/config.rb

require 'dotenv/load'
require 'notion_ruby_client'

module Config
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  def self.pg_connection
    @pg_connection ||= PG.connect(CONNECTION)
  end

  def self.notion_database_id
    ENV.fetch("NOTION_CLOSED_ISSUES_DATABASE_ID").to_s.strip
  end

  def self.notion_secret
    ENV.fetch("NOTION_SECRET").to_s.strip
  end

  def self.notion_page_id
    ENV.fetch("NOTION_CLOSED_ISSUES_PAGE_ID").to_s.strip
  end

  def self.notion_client
    NotionRubyClient::Client.new(token: notion_secret)
  end
end
