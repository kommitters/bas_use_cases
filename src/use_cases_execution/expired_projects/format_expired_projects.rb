# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_expired_projects'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'expired_projects',
  tag: 'ExpiredProjectsFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'expired_projects',
  tag: 'FormatExpiredProjects'
}

options = {
  template: Config::TEMPLATE
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  Implementation::FormatExpiredProjects.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
