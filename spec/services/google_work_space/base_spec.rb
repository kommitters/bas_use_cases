# frozen_string_literal: true

require 'rspec'
require 'googleauth'
require 'stringio'
require_relative '../../../src/services/google_work_space/base'

RSpec.describe Service::GoogleWorkSpace::Base do
  let(:admin_email) { 'test-admin@example.com' }
  let(:scope) { 'https://www.googleapis.com/auth/any_scope' }

  let(:keyfile_content) { '{"private_key": "fake"}' }
  let(:config) do
    {
      keyfile_path: '/fake/path/credentials.json',
      admin_email: admin_email
    }
  end

  let(:mock_authorizer) { instance_double(Google::Auth::ServiceAccountCredentials) }
  let(:mock_impersonated_credentials) { instance_double(Google::Auth::ServiceAccountCredentials) }

  before do
    allow(File).to receive(:open).and_return(StringIO.new(keyfile_content))

    allow(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).and_return(mock_authorizer)
    allow(mock_authorizer).to receive(:dup).and_return(mock_impersonated_credentials)
    allow(mock_impersonated_credentials).to receive(:sub=)
    allow(mock_impersonated_credentials).to receive(:fetch_access_token!)
  end

  describe '#initialize' do
    it 'authenticates using the provided service account credentials' do
      expect(Google::Auth::ServiceAccountCredentials).to receive(:make_creds).with(
        json_key_io: instance_of(StringIO),
        scope: scope
      )
      described_class.new(config, scope: scope)
    end

    it 'always impersonates the admin user' do
      expect(mock_impersonated_credentials).to receive(:sub=).with(admin_email)
      described_class.new(config, scope: scope)
    end

    it 'fetches an access token for the impersonated user' do
      expect(mock_impersonated_credentials).to receive(:fetch_access_token!)
      described_class.new(config, scope: scope)
    end

    it 'assigns the final impersonated credentials to the @credentials instance variable' do
      service = described_class.new(config, scope: scope)
      expect(service.credentials).to eq(mock_impersonated_credentials)
    end
  end
end
