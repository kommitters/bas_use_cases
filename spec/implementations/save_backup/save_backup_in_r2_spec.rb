# frozen_string_literal: true

require 'rspec'
require 'logger'
require 'aws-sdk-s3'
require_relative '../../../src/implementations/save_backup_in_r2'

RSpec.describe Implementation::SaveBackupInR2 do
  let(:options) do
    {
      connection: {
        user: 'user',
        host: 'localhost',
        port: 5432,
        dbname: 'db',
        password: 'secret'
      },
      output_file: '/tmp/bas_backup.sql.gz',
      access_key_id: 'ak',
      secret_access_key: 'sk',
      endpoint: 'https://r2.example',
      region: 'auto',
      bucket_name: 'test-bucket'
    }
  end

  let(:reader_storage) { double('SharedStorageReader') }
  let(:writer_storage) { double('SharedStorageWriter') }
  let(:subject_bot) { described_class.new(options, reader_storage, writer_storage) }

  let(:s3_client) { double('AwsS3Client') }
  let(:s3_resource) { double('AwsS3Resource') }

  before do
    allow(subject_bot).to receive(:key).and_return('20250101-000000-backup')
    allow(File).to receive(:size).with(options[:output_file]).and_return(10 * 1024 * 1024) # 10 MiB
    allow(File).to receive(:open).and_yield(double('IO'))

    allow(subject_bot).to receive(:s3_client).and_return(s3_client)
    allow(subject_bot).to receive(:s3_resource).and_return(s3_resource)

    # Avoid real logging if delete fails
    allow(Logger).to receive(:new).and_return(double('Logger', error: nil, info: nil))
  end

  def http_ok_response_with_etag(etag: '"abc"')
    http_resp = double('HttpResponse', status_code: 200)
    ctx = double('Context', http_response: http_resp)
    double('PutObjectResponse', etag: etag, context: ctx)
  end

  def http_resp(status_code)
    double('HttpResponse', status_code: status_code)
  end

  describe '#process' do
    context 'when backup creation fails' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', 'pg_dump: error',
                                                       instance_double(Process::Status, success?: false)])
      end

      it 'returns an error and does not attempt upload' do
        expect(s3_client).not_to receive(:put_object)

        result = subject_bot.process

        expect(result).to include(:error)
        expect(result[:error]).to include('error creating the dump')
      end
    end

    context 'when uploading a small backup' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', '', instance_double(Process::Status, success?: true)])

        allow(s3_client).to receive(:put_object).and_return(http_ok_response_with_etag)
        allow(File).to receive(:delete).with(options[:output_file]).and_return(1)
      end

      it 'uploads with put_object, verifies success, and deletes local file' do
        result = subject_bot.process

        expect(s3_client).to have_received(:put_object).with(
          bucket: options[:bucket_name], key: '20250101-000000-backup', body: instance_of(RSpec::Mocks::Double)
        )
        expect(File).to have_received(:delete).with(options[:output_file])
        expect(result).to eq({ success: { result: 'backup uploaded to R2 correctly. local backup deleted correctly' } })
      end
    end

    context 'when uploading a small backup fails and verification fails' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', '', instance_double(Process::Status, success?: true)])

        bad_http_resp = double('HttpResponse', status_code: 500)
        bad_ctx = double('Context', http_response: bad_http_resp)
        bad_resp = double('PutObjectResponse', etag: nil, context: bad_ctx)
        allow(s3_client).to receive(:put_object).and_return(bad_resp)
        allow(s3_client).to receive(:head_object).and_raise(Aws::S3::Errors::NotFound.new(double('RespCtx'),
                                                                                          'not found'))
      end

      it 'reports verification error and does not delete local file' do
        result = subject_bot.process
        expect(result[:success][:result]).to include('error verifying uploaded backup in R2')
        expect(result[:success][:result]).to include('local backup not uploaded, so not deleted')
      end
    end

    context 'when uploading a large backup (>= 5 GiB) succeeds via multipart' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', '', instance_double(Process::Status, success?: true)])
        allow(File).to receive(:size).with(options[:output_file]).and_return(5 * 1024 * 1024 * 1024)

        bucket = double('Bucket')
        obj = double('Object', upload_file: true, exists?: true)
        allow(s3_resource).to receive(:bucket).with(options[:bucket_name]).and_return(bucket)
        allow(bucket).to receive(:object).with('20250101-000000-backup').and_return(obj)

        allow(File).to receive(:delete).with(options[:output_file]).and_return(1)
      end

      it 'uses multipart uploader and deletes local file' do
        result = subject_bot.process
        expect(result).to eq({ success: { result: 'backup uploaded to R2 correctly. local backup deleted correctly' } })
      end
    end

    context 'when local file deletion fails with ENOENT' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', '', instance_double(Process::Status, success?: true)])
        allow(s3_client).to receive(:put_object).and_return(http_ok_response_with_etag)
        allow(File).to receive(:delete).with(options[:output_file]).and_raise(Errno::ENOENT)
      end

      it 'reports the deletion error in the final message' do
        result = subject_bot.process
        expect(result[:success][:result]).to include('backup uploaded to R2 correctly')
        expect(result[:success][:result]).to include('No such file or directory')
      end
    end
  end
end
