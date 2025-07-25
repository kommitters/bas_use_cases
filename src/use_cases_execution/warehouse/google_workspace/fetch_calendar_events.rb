# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/postgres'

require_relative '../../../implementations/fetch_workspace_calendar_events'
require_relative 'config'

read_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  avoid_process: true,
  where: 'archived=$1 AND tag=$2 ORDER BY inserted_at DESC',
  params: [false, 'FetchWorkspaceCalendarEvents']
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'warehouse_sync',
  tag: 'FetchWorkspaceCalendarEvents'
}

options = {
  google_keyfile_path: Config::GOOGLE_KEYFILE_PATH,
  google_admin_email: Config::GOOGLE_ADMIN_EMAIL
}

begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::FetchWorkspaceCalendarEvents.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
