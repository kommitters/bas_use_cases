# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/delete_older_backup_in_r2'
require_relative 'config'

# Configuration

options = {
  backups_limit: Config::BACKUPS_LIMIT.to_i,
  access_key_id: Config::R2_CONFIG[:access_key_id],
  secret_access_key: Config::R2_CONFIG[:secret_access_key],
  endpoint: Config::R2_CONFIG[:endpoint],
  region: Config::R2_CONFIG[:region],
  bucket_name: Config::R2_CONFIG[:bucket_name]
}

read_options = {
  connection: Config::CONNECTION,
  db_table: 'backups',
  tag: 'SavedBackup'
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'backups',
  tag: 'DeletedBackup'
}

# Process bot
begin
  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })

  Implementation::DeleteOlderBackupInR2.new(options, shared_storage).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
