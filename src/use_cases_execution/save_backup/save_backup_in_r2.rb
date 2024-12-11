# frozen_string_literal: true

require 'logger'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

require_relative '../../implementations/save_backup_in_r2'
require_relative 'config'

# Configuration

options = {
  connection: Config::CONNECTION,
  output_file: '/app/backup/bas_backup.sql',
  access_key_id: Config::R2_CONFIG[:access_key_id],
  secret_access_key: Config::R2_CONFIG[:secret_access_key],
  endpoint: Config::R2_CONFIG[:endpoint],
  region: Config::R2_CONFIG[:region],
  bucket_name: Config::R2_CONFIG[:bucket_name]
}

write_options = {
  connection: Config::CONNECTION,
  db_table: 'backups',
  tag: 'SavedBackup'
}

# Process bot
begin
  shared_storage_reader = Bas::SharedStorage::Default.new
  shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })

  Implementation::SaveBackupInR2.new(options, shared_storage_reader, shared_storage_writer).execute
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
