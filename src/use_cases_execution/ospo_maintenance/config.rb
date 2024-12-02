# frozen_string_literal: true

#   INSTRUCTIONS:
#
#   This file is used to store the configuration of the birthday use case.
#   It contains the connection information to the database and the schedule of the bot.
#   The schedule configuration has two fields: path and interval.
#   The path is the path to the script that will be executed
#   The interval is the time in milliseconds that the script will be executed

require 'dotenv/load'

module OspoMaintenanceConfig
  # PRIVATE_PEM = File.read('/app/github_private_key.pem')
  APP_ID = ENV.fetch('OSPO_MAINTENANCE_APP_ID')
  ORGANIZATION = 'kommitters'
  DOMAIN = 'kommit.engineering'
  WORK_ITEM_TYPE = 'activity'

  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }.freeze

  SCHEDULE = [
    { path: '/ospo_maintenance/create_work_item.rb', interval: 600_000 },
    { path: '/ospo_maintenance/update_work_item.rb', interval: 600_000 },
    { path: '/ospo_maintenance/verify_issue_existance_in_notion.rb', interval: 600_000 }
  ].freeze
end
