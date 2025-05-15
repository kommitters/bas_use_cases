# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/fetch_scores_from_github'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'repos_score',
  tag: 'FetchRepositoriesFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'repos_score',
  tag: 'FetchScoresFromGithub'
}

options = {
  api_url: ENV.fetch('API_SECURITY_SCORECARDS_URL')
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchScoresFromGithub.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
