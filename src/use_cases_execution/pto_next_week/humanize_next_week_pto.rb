# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/humanize_pto'
require_relative 'config'

# Configuration
utc_today = Time.now.utc
today = Time.at(utc_today, in: '-05:00').strftime('%F').to_s

read_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'FetchNextWeekPtosFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'pto',
  tag: 'HumanizeNextWeekPto'
}

options = {
  secret: ENV.fetch('OPENAI_SECRET'),
  assistant_id: ENV.fetch('NEXT_WEEK_PTO_OPENAI_ASSISTANT'),
  prompt: "Today is #{today} and the PTO's are: {data}"
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Bot::HumanizePto.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
