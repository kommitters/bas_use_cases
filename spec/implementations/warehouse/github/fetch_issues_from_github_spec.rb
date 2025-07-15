# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require 'ostruct'
require_relative '../../../../src/implementations/fetch_issues_from_github'
require_relative '../../../../src/utils/warehouse/github/issues_format'

RSpec.describe Implementation::FetchIssuesFromGithub do
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
  let(:repo1) { OpenStruct.new(full_name: 'fake-org/repo1') }
  let(:issue1) { OpenStruct.new(id: 1, title: 'Test Issue 1') }
  let(:formatter) { instance_double(Utils::Warehouse::Github::IssuesFormatter) }

  before do
    allow(Utils::Github::OctokitClient).to receive(:new).and_return(octokit_client_wrapper)
    allow(octokit_client_wrapper).to receive(:execute).and_return({ client: octokit_client })
    allow(octokit_client).to receive(:auto_paginate=)
    allow(octokit_client).to receive(:organization_repositories).with('fake-org').and_return([repo1])
    allow(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).and_return(formatter)
    allow(formatter).to receive(:format).and_return({ normalized_issue: true })
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

    context 'when fetching issues' do
      let(:last_response) { double('last_response', rels: { next: nil }) }

      before do
        # Common mock for pagination termination
        allow(octokit_client).to receive(:last_response).and_return(last_response)
      end

      context 'on the first run (no last_run_timestamp)' do
        before do
          # FIX: Allow the :read method call and simulate no previous run
          allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))
          # CORRECTED: Use hash_including to match the options hash correctly.
          allow(octokit_client).to receive(:issues)
            .with('fake-org/repo1', hash_including(state: 'all', per_page: 100))
            .and_return([issue1])
        end

        it 'fetches all issues and formats them' do
          result = bot.process
          expect(result).to have_key(:success)
          expect(result.dig(:success, :type)).to eq('github_issue')
          expect(result.dig(:success, :content)).to eq([{ normalized_issue: true }])
        end
      end

      context 'on an incremental run (last_run_timestamp exists)' do
        let(:timestamp) { Time.now - 3600 }

        before do
          # Simulate a previous run
          allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: timestamp))
          # CORRECTED: Use hash_including for the options hash with the 'since' parameter.
          allow(octokit_client).to receive(:issues)
            .with('fake-org/repo1', hash_including(state: 'all', per_page: 100, since: timestamp.iso8601))
            .and_return([issue1])
        end

        it 'fetches issues since the last run' do
          expect { bot.process }.not_to raise_error
        end
      end

      context 'when there are multiple pages of issues' do
        let(:issue2) { OpenStruct.new(id: 2, title: 'Test Issue 2') }
        let(:page1_response) { double('page1_response', rels: { next: page2_link }) }
        let(:page2_link) { double('page2_link', get: page2_response) }
        let(:page2_response) { double('page2_response', data: [issue2], rels: { next: nil }) }

        before do
          allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))
          allow(octokit_client).to receive(:issues).and_return([issue1])
          # Mock the pagination chain
          allow(octokit_client).to receive(:last_response).and_return(page1_response, page2_response)
          allow(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).with(issue1, repo1).and_return(formatter)
          allow(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).with(issue2, repo1).and_return(formatter)
        end

        it 'fetches all pages and concatenates the issues' do
          result = bot.process
          expect(result.dig(:success, :content).size).to eq(2)
        end
      end
    end
  end

  describe '#write' do
    let(:content) { Array.new(150) { { normalized_issue: true } } }
    let(:process_response) { { success: { type: 'github_issue', content: content } } }

    before do
      allow(bot).to receive(:process_response).and_return(process_response)
    end

    it 'writes records in pages of 100' do
      expect(shared_storage).to receive(:write).exactly(2).times
      bot.write
    end

    it 'builds the record with correct pagination metadata' do
      first_page_record = {
        success: {
          type: 'github_issue',
          content: Array.new(100) { { normalized_issue: true } },
          page_index: 1,
          total_pages: 2,
          total_records: 150
        }
      }
      second_page_record = {
        success: {
          type: 'github_issue',
          content: Array.new(50) { { normalized_issue: true } },
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
      allow(bot).to receive(:process_response).and_return({ success: { type: 'github_issue', content: [] } })
      expect(shared_storage).not_to receive(:write)
      bot.write
    end
  end
end
