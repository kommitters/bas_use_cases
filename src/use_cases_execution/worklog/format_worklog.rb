# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/format_worklog'
require_relative 'config'

# Configuration
read_options = {
  connection: Config::CONNECTION,
  db_table: 'worklog',
  tag: 'FetchWorklogsFromNotion'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'worklog',
  tag: 'FormatWorklogs'
}

options = {
  person_section_template: '**<person_name>**',
  worklog_item_template: '- <hours>h: <detail>',
  no_detail_message: 'Sin detalle especificado'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FormatWorklogs.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
