# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/pto_next_week/humanize_next_week_pto'

# Configuration
params = {
  openai_secret: ENV.fetch('OPENAI_SECRET'),
  openai_assistant: ENV.fetch('NEXT_WEEK_PTO_OPENAI_ASSISTANT'),
  table_name: 'pto',
  db_host: ENV.fetch('DB_HOST'),
  db_port: ENV.fetch('DB_PORT'),
  db_name: ENV.fetch('POSTGRES_DB'),
  db_user: ENV.fetch('POSTGRES_USER'),
  db_password: ENV.fetch('POSTGRES_PASSWORD')
}

# Process bot
begin
  bot = Humanize::NextWeekPto.new(params)

  bot.execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
