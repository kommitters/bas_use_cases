# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require 'ostruct'
require_relative '../../../../src/implementations/fetch_releases_from_github'
require_relative '../../../../src/utils/warehouse/github/releases_format'

RSpec.describe Implementation::FetchReleasesFromGithub do
  subject(:bot) { described_class.new(options, shared_storage) }

  let(:options) do
    {
      private_pem: 'fake_pem',
      app_id: 'fake_app_id',
      organization: 'fake-org'
    }
  end

  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:octokit_client_wrapper) { instance_double(Utils::Github::OctokitClient) }
  let(:octokit_client) { instance_double(Octokit::Client) }

  before do
    allow(Utils::Github::OctokitClient).to receive(:new).and_return(octokit_client_wrapper)
    allow(octokit_client).to receive(:auto_paginate=)
    allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
  end

  describe '#process' do
    context 'when OctokitClient fails to authenticate' do
      before do
        allow(octokit_client_wrapper).to receive(:execute).and_return({ error: 'Authentication failed' })
      end

      it 'returns an error hash' do
        result = bot.process
        expect(result).to have_key(:error)
        expect(result[:error]).to eq('Authentication failed')
      end
    end

    context 'when API calls are successful' do
      let(:repo1) { OpenStruct.new(full_name: 'fake-org/repo1') }
      let(:release1) { OpenStruct.new(id: 1, name: 'Release 1') }
      let(:formatter) { instance_double(Utils::Warehouse::Github::ReleasesFormat) }

      before do
        allow(octokit_client_wrapper).to receive(:execute).and_return({ client: octokit_client })
        allow(octokit_client).to receive(:organization_repositories).with('fake-org').and_return([repo1])
        allow(octokit_client).to receive(:releases).with('fake-org/repo1', per_page: 100).and_return([release1])
        allow(Utils::Warehouse::Github::ReleasesFormat).to receive(:new).with(release1, repo1).and_return(formatter)
        allow(formatter).to receive(:format).and_return({ normalized: true })
      end

      it 'fetches releases and formats them' do
        result = bot.process
        expect(result).to have_key(:success)
        expect(result.dig(:success, :type)).to eq('github_release')
        expect(result.dig(:success, :content)).to eq([{ normalized: true }])
      end
    end
  end

  describe '#write' do
    let(:content) { Array.new(150) { { normalized: true } } } # 150 items
    let(:process_response) { { success: { type: 'github_release', content: content } } }

    before do
      allow(bot).to receive(:process_response).and_return(process_response)
    end

    it 'writes records in pages of 100' do
      # Expect 2 pages for 150 items (100, 50)
      expect(shared_storage).to receive(:write).exactly(2).times
      bot.write
    end

    it 'builds the record with correct pagination metadata' do
      first_page_record = {
        success: {
          type: 'github_release',
          content: Array.new(100) { { normalized: true } },
          page_index: 1,
          total_pages: 2,
          total_records: 150
        }
      }
      second_page_record = {
        success: {
          type: 'github_release',
          content: Array.new(50) { { normalized: true } },
          page_index: 2,
          total_pages: 2,
          total_records: 150
        }
      }
      expect(shared_storage).to receive(:write).with(first_page_record).ordered
      expect(shared_storage).to receive(:write).with(second_page_record).ordered
      bot.write
    end

    it 'does not write anything if content is empty' do
      allow(bot).to receive(:process_response).and_return({ success: { type: 'github_release', content: [] } })
      expect(shared_storage).not_to receive(:write)
      bot.write
    end
  end
end
