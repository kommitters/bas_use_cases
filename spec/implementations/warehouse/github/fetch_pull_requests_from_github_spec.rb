# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'bas/utils/github/octokit_client'
require_relative '../../../../src/implementations/fetch_pull_requests_from_github'
require_relative '../../../../src/utils/warehouse/github/pull_requests_format'

RSpec.describe Implementation::FetchPullRequestsFromGithub do
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
    # Mock read_response to avoid dependency on actual storage reads in tests
    allow(bot).to receive(:read_response).and_return({ success: { content: [] } })
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
      let(:repo1) { { id: 1, full_name: 'fake-org/repo1' } }
      let(:release1) { { id: 101, published_at: Time.now + 1 } }
      let(:pr1) { { id: 201, number: 42, body: 'closes #123', merged_at: Time.now } }
      let(:review1) { { id: 301 } }
      let(:comment1) { { id: 401 } }
      let(:related_issue1) { { id: 501 } }
      let(:formatter) { instance_double(Utils::Warehouse::Github::PullRequestsFormat) }
      let(:context_matcher) do
        {
          reviews: [review1],
          comments: [comment1],
          related_issues: [related_issue1],
          releases: [release1].sort_by { |r| r[:published_at] }.reverse
        }
      end

      before do
        allow(octokit_client_wrapper).to receive(:execute).and_return({ client: octokit_client })
        allow(octokit_client).to receive(:organization_repositories).with('fake-org').and_return([repo1])
        allow(octokit_client).to receive(:releases).with('fake-org/repo1').and_return([release1])
        allow(octokit_client).to receive(:pull_requests).with('fake-org/repo1', state: 'all', per_page: 100)
                             .and_return([pr1])
        allow(octokit_client).to receive(:pull_request_reviews).with('fake-org/repo1', 42).and_return([review1])
        allow(octokit_client).to receive(:pull_request_comments).with('fake-org/repo1', 42).and_return([comment1])
        allow(octokit_client).to receive(:issue).with('fake-org/repo1', 123).and_return(related_issue1)

        # Mock the formatter instantiation and its format call
        allow(Utils::Warehouse::Github::PullRequestsFormat).to receive(:new).with(pr1, repo1, context_matcher)
                                                           .and_return(formatter)
        allow(formatter).to receive(:format).and_return({ normalized_pr: true })
      end

      it 'fetches all related PR data and formats it' do
        result = bot.process
        expect(result).to have_key(:success)
        expect(result.dig(:success, :type)).to eq('github_pull_request')
        expect(result.dig(:success, :content)).to eq([{ normalized_pr: true }])
      end
    end
  end

  describe '#write' do
    let(:content) { Array.new(150) { { normalized_pr: true } } } # 150 items
    let(:process_response) { { success: { type: 'github_pull_request', content: content } } }

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
          type: 'github_pull_request',
          content: Array.new(100) { { normalized_pr: true } },
          page_index: 1,
          total_pages: 2,
          total_records: 150
        }
      }
      second_page_record = {
        success: {
          type: 'github_pull_request',
          content: Array.new(50) { { normalized_pr: true } },
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
      allow(bot).to receive(:process_response).and_return({ success: { type: 'github_pull_request', content: [] } })
      expect(shared_storage).not_to receive(:write)
      bot.write
    end
  end
end
