# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/update_scores_in_notion'
require_relative 'config'


read_options = {
  connection: Config::CONNECTION,
  db_table: 'repos_score',
  tag: 'FetchScoresFromGithub'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'repos_score',
  tag: 'UpdateScoresInNotion'
}

options = {
  secret: ENV.fetch('NOTION_SECRET')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::UpdateScoresInNotion.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
