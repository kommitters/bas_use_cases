# frozen_string_literal: true

require 'logger'

require_relative '../../use_cases/wip_limit/compare_wip_limit_count'

# Configuration
params = {
  table_name: ENV.fetch('WIP_TABLE'),
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('DB_NAME'),
  db_user: ENV.fetch('DB_USER'),
  db_password: ENV.fetch('DB_PASSWORD')
}

# Process bot
begin
  bot = Compare::WipLimitCount.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
