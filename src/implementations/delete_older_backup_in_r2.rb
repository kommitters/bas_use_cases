# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'aws-sdk-s3'

module Implementation
  ##
  # The Implementation::DeleteOlderBackupInR2 class serves as a bot implementation to delete the
  # older object on an AWS S3 bucket depending on a maximum limit
  #
  # <br>
  # <b>Example</b>
  #
  #   options = {
  #     backups_limit: 5,
  #     access_key_id: 'access_key_id',
  #     secret_access_key: 'secret_access_key',
  #     endpoint: 'endpoint',
  #     region: 'region',
  #     bucket_name: 'bucket_name'
  #   }
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'backups',
  #     tag: 'SavedBackup'
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'backups',
  #     tag: 'DeletedBackup'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::DeleteOlderBackupInR2.new(options, shared_storage).execute
  #
  class DeleteOlderBackupInR2 < Bas::Bot::Base
    def process
      return { success: nil } if unprocessable_response

      backups = list_bucket_objects[:contents]

      return { success: { result: nil } } unless backups.size > process_options[:backups_limit]

      older_backup_key = backups.min_by(&:last_modified).key
      delete_object(older_backup_key)

      { success: { result: "#{older_backup_key} backup deleted" } }
    rescue Aws::S3::Errors::ServiceError => e
      { error: { r2_api: e.message } }
    end

    private

    def list_bucket_objects
      s3_client.list_objects(
        bucket: process_options[:bucket_name]
      )
    end

    def delete_object(object_key)
      s3_client.delete_object(
        bucket: process_options[:bucket_name],
        key: object_key
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
  end
end
