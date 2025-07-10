# frozen_string_literal: true

require 'dotenv/load'

##
# This file stores the configuration for GitHub related implementations.
# It loads credentials and constants from environment variables.
#
module Config
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  GITHUB_PRIVATE_PEM = ENV.fetch('GITHUB_PRIVATE_PEM')
  GITHUB_APP_ID = ENV.fetch('GITHUB_APP_ID')

  KOMMITERS_ORGANIZATION = 'kommitters '
  KOMMIT_CO_ORGANIZATION = 'kommit-co'
end
