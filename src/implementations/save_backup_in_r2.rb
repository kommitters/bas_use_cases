# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'aws-sdk-s3'
require 'open3'
require 'logger'
require 'shellwords'

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
    def process # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
      dump_result = create_backup
      return dump_result if dump_result[:error]

      upload_result = save_dump_in_r2
      result_status = upload_result[:success] ? 'backup uploaded to R2 correctly' : upload_result[:error]
      return { error: result_status } unless upload_result[:success]

      delete_result = upload_result[:success] ? delete_backup : { error: 'local backup not uploaded, so not deleted' }
      delete_status = delete_result[:success] ? 'local backup deleted correctly' : delete_result[:error]
      return { error: "#{result_status}. #{delete_status}" } unless delete_result[:success]

      { success: { result: "#{result_status}. #{delete_status}" } }
    rescue Aws::S3::Errors::ServiceError => e
      { error: { backup: dump_result, r2_api: e.message } }
    end

    private

    def create_backup
      env = { 'PGPASSWORD' => process_options[:connection][:password].to_s }
      _stdout, stderr, status = Open3.capture3(env, 'bash', '-lc', backup_command)
      return { success: :ok } if status.success?

      { error: "error creating the dump: #{stderr.strip}" }
    end

    def backup_command # rubocop:disable Metrics/AbcSize
      db_user = Shellwords.escape(process_options[:connection][:user].to_s)
      db_host = Shellwords.escape(process_options[:connection][:host].to_s)
      db_port = Shellwords.escape(process_options[:connection][:port].to_s)
      db_name = Shellwords.escape(process_options[:connection][:dbname].to_s)
      out = Shellwords.escape(output_file.to_s)

      "set -o pipefail; pg_dump -U #{db_user} -h #{db_host} -p #{db_port} #{db_name} | gzip > #{out}"
    end

    def delete_backup
      File.delete(output_file) == 1 ? { success: true } : { error: 'local dump file not deleted' }
    rescue SystemCallError => e
      Logger.new($stdout).error("#{e.class}: #{e.message}")
      { error: "#{e.class}: #{e.message}" }
    end

    def output_file
      process_options[:output_file]
    end

    def save_dump_in_r2
      object_key = key
      bucket_name = process_options[:bucket_name]
      file_size = File.size(output_file)
      result = upload_file(object_key, bucket_name, file_size)

      return { success: true } if successful_upload?(result)
      return { success: true } if verify_upload(object_key, bucket_name, file_size)

      { error: 'error verifying uploaded backup in R2' }
    rescue StandardError => e
      { error: "#{e.class}: #{e.message}" }
    end

    def upload_file(object_key, bucket_name, file_size)
      result = nil

      if file_size >= 5 * 1024 * 1024 * 1024
        obj = s3_resource.bucket(bucket_name).object(object_key)
        result = obj.upload_file(output_file) ? obj : nil
      else
        File.open(output_file, 'rb') do |io|
          result = s3_client.put_object(bucket: bucket_name, key: object_key, body: io)
        end
      end

      result
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

    def s3_resource
      Aws::S3::Resource.new(client: s3_client)
    end

    def successful_upload?(result)
      return false if result.nil?

      if result.respond_to?(:context)
        return result.context.http_response.status_code.between?(200, 299) && result.etag&.length&.positive?
      end

      return result.exists? if result.respond_to?(:exists?)

      false
    end

    def verify_upload(object_key, bucket_name, expected_size)
      head = s3_client.head_object(bucket: bucket_name, key: object_key)
      head.context.http_response.status_code.between?(200, 299) && head.content_length.to_i == expected_size.to_i
    rescue Aws::S3::Errors::NotFound
      false
    end

    def key
      Time.now.strftime('%F-%T-backup').gsub(':', '')
    end
  end
end
