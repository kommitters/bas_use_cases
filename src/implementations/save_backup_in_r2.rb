# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'aws-sdk-s3'

module Implementation
  ##
  # The Implementation::SaveBackupInR2 class serves as a bot implementation to create a
  # postgres dump of a database and save it into a AWS S3 bucket.
  #
  # <br>
  # <b>Example</b>
  #
  #   options = {
  #     connection: Config::CONNECTION,
  #     output_file: '/app/backup/bas_backup.sql',
  #     access_key_id: 'access_key_id',
  #     secret_access_key: 'secret_access_key',
  #     endpoint: 'endpoint',
  #     region: 'region',
  #     bucket_name: 'bucket_name'
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'backups',
  #     tag: 'SavedBackup'
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #   Implementation::SaveBackupInR2.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class SaveBackupInR2 < Bas::Bot::Base
    def process
      dump_result = create_backup
      save_dump_in_r2

      { success: { result: 'backup saved correctly' } }
    rescue Aws::S3::Errors::ServiceError => e
      { error: { backup: dump_result, r2_api: e.message } }
    end

    private

    def create_backup
      system(command) ? { success: :ok } : { error: 'error creating the dump' }
    end

    def command
      db_user = process_options[:connection][:user]
      db_host = process_options[:connection][:host]
      db_port = process_options[:connection][:port]
      db_name = process_options[:connection][:dbname]
      password = process_options[:connection][:password]

      "PGPASSWORD='#{password}' pg_dump -U #{db_user} -h #{db_host} -p #{db_port} #{db_name} | gzip > #{output_file}"
    end

    def output_file
      process_options[:output_file]
    end

    def save_dump_in_r2
      s3_client.put_object(
        bucket: process_options[:bucket_name],
        body: File.open(output_file, 'rb'),
        key:
      )
    end

    def s3_client
      Aws::S3::Client.new(
        access_key_id: process_options[:access_key_id],
        secret_access_key: process_options[:secret_access_key],
        endpoint: process_options[:endpoint],
        region: process_options[:region],
        force_path_style: true
      )
    end

    def key
      Time.now.strftime('%F-%T-backup')
    end
  end
end
