# frozen_string_literal: true

require 'dotenv/load'

##
# Config is the central module for all warehouse application configuration.
# It provides a single source of truth for credentials, endpoints, and constants,
# loaded from environment variables.
#
module Config
  # A dedicated, reusable place for helper methods.
  module Helpers
    module_function

    def fetch_required_env(key)
      ENV.fetch(key) do
        raise KeyError, "#{key} is not set in environment variables"
      end
    end
  end

  ##
  # Contains configuration for database connections.
  #
  module Database
    CONNECTION = {
      host: ENV.fetch('DB_HOST'),
      port: ENV.fetch('DB_PORT'),
      dbname: ENV.fetch('POSTGRES_DB'),
      user: ENV.fetch('POSTGRES_USER'),
      password: ENV.fetch('POSTGRES_PASSWORD')
    }.freeze

    WAREHOUSE_CONNECTION = {
      host: ENV.fetch('DB_HOST_WAREHOUSE'),
      port: ENV.fetch('DB_PORT_WAREHOUSE'),
      dbname: ENV.fetch('WAREHOUSE_POSTGRES_DB'),
      user: ENV.fetch('POSTGRES_USER_WAREHOUSE'),
      password: ENV.fetch('POSTGRES_PASSWORD_WAREHOUSE')
    }.freeze
  end

  ##
  # Contains configuration specific to the Notion integration.
  #
  module Notion
    SECRET = ENV.fetch('NOTION_SECRET')
    PROJECTS_DATABASE_ID = ENV.fetch('PROJECTS_NOTION_DATABASE_ID')
    ACTIVITIES_DATABASE_ID = ENV.fetch('ACTIVITIES_NOTION_DATABASE_ID')
    WORK_ITEMS_DATABASE_ID = ENV.fetch('WORK_ITEMS_NOTION_DATABASE_ID')
    DOMAINS_DATABASE_ID = ENV.fetch('DOMAINS_NOTION_DATABASE_ID')
    DOCUMENTS_DATABASE_ID = ENV.fetch('DOCUMENTS_NOTION_DATABASE_ID')
    WEEKLY_SCOPES_DATABASE_ID = ENV.fetch('WEEKLY_SCOPES_NOTION_DATABASE_ID')
    PERSONS_DATABASE_ID = ENV.fetch('PERSONS_NOTION_DATABASE_ID')
    KEY_RESULTS_DATABASE_ID = ENV.fetch('KEY_RESULTS_NOTION_DATABASE_ID')
    HIRED_PERSONS_DATABASE_ID = ENV.fetch('HIRED_PERSONS_NOTION_DATABASE_ID')
    KPIS_DATABASE_ID = ENV.fetch('KPIS_NOTION_DATABASE_ID')
  end

  ##
  # Contains configuration specific to the WorkLogs integration.
  #
  module Worklogs
    URL = ENV.fetch('WORK_LOGS_URL')
    API_SECRET = ENV.fetch('WORK_LOGS_API_SECRET')
  end

  ##
  # Contains configuration for the GitHub App integration.
  #
  module Github
    def self.kommiters
      {
        private_pem: File.read('./kommiters_private_key.pem'),
        app_id: ENV.fetch('KOMMITERS_GITHUB_APP_ID'),
        organization: 'kommitters'
      }
    end

    def self.kommit_co
      {
        private_pem: File.read('./kommit_co_private_key.pem'),
        app_id: ENV.fetch('KOMMIT_CO_GITHUB_APP_ID'),
        organization: 'kommit-co'
      }
    end
  end

  ##
  # Contains configuration specific to the Operaton integration.
  #
  module Operaton
    extend Helpers

    BASE_URI = fetch_required_env('OPERATON_API_BASE_URI')
    USER_ID = fetch_required_env('OPERATON_USER_ID')
    PASSWORD_SECRET = fetch_required_env('OPERATON_PASSWORD_SECRET')
  end
end
