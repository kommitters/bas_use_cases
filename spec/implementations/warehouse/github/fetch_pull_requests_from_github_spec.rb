# frozen_string_literal: true

# require 'spec_helper'
# require 'bas/shared_storage/postgres'
# require 'bas/utils/github/octokit_client'
# require 'ostruct'
# require_relative '../../../../src/implementations/fetch_pull_requests_from_github'
# require_relative '../../../../src/utils/warehouse/github/pull_requests_format'

# RSpec.describe Implementation::FetchPullRequestsFromGithub do
#   subject(:bot) { described_class.new(options, shared_storage) }

#   let(:options) do
#     {
#       private_pem: 'fake_pem',
#       app_id: 'fake_app_id',
#       organization: 'fake-org'
#     }
#   end

#   let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
#   let(:octokit_client_wrapper) { instance_double(Utils::Github::OctokitClient) }
#   let(:octokit_client) { instance_double(Octokit::Client) }

#   # Data Mocks - Added 'name' and 'archived' for the new logic
#   let(:repo1) { OpenStruct.new(id: 1, full_name: 'fake-org/repo1', name: 'repo1', archived: false) }
#   let(:formatter) { instance_double(Utils::Warehouse::Github::PullRequestsFormat) }

#   # Helper timestamps
#   let(:now) { Time.now }
#   let(:old_time) { now - 86_400 } # 1 day ago

#   # Mock Objects
#   let(:release1) { OpenStruct.new(id: 101, published_at: now) }
#   let(:review1) { OpenStruct.new(id: 301) }
#   # Comments removed from optimization

#   # PR with related issue in body
#   let(:pr1) do
#     OpenStruct.new(
#       id: 201,
#       number: 42,
#       body: 'closes #123',
#       updated_at: now,
#       created_at: now
#     )
#   end

#   before do
#     # Suppress stdout logs during tests to keep output clean
#     allow($stdout).to receive(:puts)
#     allow($stdout).to receive(:print)

#     allow(Utils::Github::OctokitClient).to receive(:new).and_return(octokit_client_wrapper)
#     allow(octokit_client_wrapper).to receive(:execute).and_return({ client: octokit_client })
#     allow(octokit_client).to receive(:auto_paginate=)

#     allow(octokit_client).to receive(:dup).and_return(octokit_client)

#     allow(octokit_client).to receive(:organization_repositories)
#       .with('fake-org', hash_including(page: 1, per_page: 100))
#       .and_return([repo1])

#     # Releases Map Setup - accepts any args to avoid strict matching issues in threads
#     allow(octokit_client).to receive(:releases).with('fake-org/repo1', anything).and_return([release1])

#     # Formatter Setup
#     allow(Utils::Warehouse::Github::PullRequestsFormat).to receive(:new).and_return(formatter)
#     allow(formatter).to receive(:format).and_return({ normalized_pr: true })
#   end

#   describe '#process' do
#     context 'when OctokitClient fails to authenticate' do
#       before do
#         allow(octokit_client_wrapper).to receive(:execute).and_return({ error: 'Authentication failed' })
#       end

#       it 'returns an error hash' do
#         result = bot.process
#         expect(result).to have_key(:error)
#         expect(result.dig(:error, :message)).to eq('Authentication failed')
#       end
#     end

#     context 'when fetching pull requests successfully' do
#       let(:last_response) { double('last_response', rels: { next: nil }) }
#       let(:repo_response_no_next) { double('repo_response', rels: { next: nil }) }

#       # Correct params as per implementation
#       let(:pr_api_params) do
#         { state: 'all', sort: 'updated', direction: 'desc', per_page: 100 }
#       end

#       before do
#         allow(octokit_client).to receive(:last_response).and_return(repo_response_no_next, last_response)

#         # Sub-resources mocks
#         allow(octokit_client).to receive(:pull_request_reviews).with('fake-org/repo1', 42).and_return([review1])
#       end

#       context 'on the first run (no last_run_timestamp)' do
#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           allow(octokit_client).to receive(:pull_requests)
#             .with('fake-org/repo1', pr_api_params)
#             .and_return([pr1])
#         end

#         it 'fetches PRs, builds the context with related issues, and formats them' do
#           # Updated expected context (no comments)
#           expected_context = {
#             reviews: [review1],
#             related_issues: [123],
#             releases: [release1]
#           }

#           expect(Utils::Warehouse::Github::PullRequestsFormat).to receive(:new)
#             .with(pr1, repo1, expected_context)
#             .and_return(formatter)

#           result = bot.process
#           expect(result[:success][:content]).to eq([{ normalized_pr: true }])
#         end
#       end

#       context 'when repositories span multiple pages' do
#         let(:repo2) { OpenStruct.new(id: 2, full_name: 'fake-org/repo2', name: 'repo2', archived: false) }
#         let(:pr_repo1) { OpenStruct.new(id: 1, number: 1, body: nil, updated_at: now) }
#         let(:pr_repo2) { OpenStruct.new(id: 2, number: 2, body: nil, updated_at: now) }

#         # Mock responses for repo pagination
#         let(:repo_page1_resp) { double('resp_p1', rels: { next: true }) }
#         let(:repo_page2_resp) { double('resp_p2', rels: { next: nil }) }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           # Page 1 fetch
#           allow(octokit_client).to receive(:organization_repositories)
#             .with('fake-org', hash_including(page: 1))
#             .and_return([repo1])

#           # Page 2 fetch
#           allow(octokit_client).to receive(:organization_repositories)
#             .with('fake-org', hash_including(page: 2))
#             .and_return([repo2])

#           allow(octokit_client).to receive(:last_response).and_return(
#             repo_page1_resp,
#             repo_page2_resp,
#             last_response
#           )

#           allow(octokit_client).to receive(:releases).and_return([])
#           allow(octokit_client).to receive(:pull_requests).with('fake-org/repo1', any_args).and_return([pr_repo1])
#           allow(octokit_client).to receive(:pull_requests).with('fake-org/repo2', any_args).and_return([pr_repo2])
#           allow(octokit_client).to receive(:pull_request_reviews).and_return([])
#         end

#         it 'iterates through repository pages and collects PRs from all repos' do
#           result = bot.process
#           content = result.dig(:success, :content)
#           expect(content.size).to eq(2)
#         end
#       end

#       context 'on an incremental run (last_run_timestamp exists)' do
#         let(:last_run) { now - 3600 } # 1 hour ago
#         let(:pr_new) { OpenStruct.new(id: 1, number: 1, updated_at: now, body: '') }
#         let(:pr_old) { OpenStruct.new(id: 2, number: 2, updated_at: old_time, body: '') }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: last_run))

#           allow(octokit_client).to receive(:pull_requests)
#             .with('fake-org/repo1', pr_api_params)
#             .and_return([pr_new, pr_old])

#           allow(octokit_client).to receive(:pull_request_reviews).with('fake-org/repo1', 1).and_return([])
#         end

#         it 'filters out PRs not updated since last run' do
#           expect(Utils::Warehouse::Github::PullRequestsFormat).to receive(:new).with(pr_new, repo1, anything)
#           expect(Utils::Warehouse::Github::PullRequestsFormat).not_to receive(:new).with(pr_old, any_args)

#           result = bot.process
#           expect(result[:success][:content].size).to eq(1)
#         end
#       end

#       context 'when pagination is required (inside a repo)' do
#         let(:pr_page1) { OpenStruct.new(id: 1, number: 1, updated_at: now, body: '') }
#         let(:pr_page2) { OpenStruct.new(id: 2, number: 2, updated_at: now, body: '') }

#         # Pagination Mocks
#         let(:page1_response) { double('page1_response', data: [pr_page1], rels: { next: page2_link }) }
#         let(:page2_link) { double('page2_link', get: page2_response) }
#         let(:page2_response) { double('page2_response', data: [pr_page2], rels: { next: nil }) }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           allow(octokit_client).to receive(:releases).and_return([])

#           allow(octokit_client).to receive(:pull_requests).and_return([pr_page1])

#           allow(octokit_client).to receive(:last_response).and_return(
#             repo_response_no_next,
#             page1_response
#           )

#           allow(octokit_client).to receive(:pull_request_reviews).and_return([])
#         end

#         it 'iterates through pages and collects all PRs' do
#           result = bot.process
#           content = result.dig(:success, :content)
#           expect(content.size).to eq(2)
#         end
#       end
#     end
#   end

#   describe '#write' do
#     let(:content) { Array.new(150) { { normalized_pr: true } } }
#     let(:process_response) { { success: { type: 'github_pull_request', content: content } } }

#     before do
#       allow(bot).to receive(:process_response).and_return(process_response)
#     end

#     it 'writes records in pages of 100' do
#       expect(shared_storage).to receive(:write).exactly(2).times
#       bot.write
#     end

#     it 'builds the record with correct pagination metadata' do
#       first_page_record = {
#         success: {
#           type: 'github_pull_request',
#           content: Array.new(100) { { normalized_pr: true } },
#           page_index: 1,
#           total_pages: 2,
#           total_records: 150
#         }
#       }

#       second_page_record = {
#         success: {
#           type: 'github_pull_request',
#           content: Array.new(50) { { normalized_pr: true } },
#           page_index: 2,
#           total_pages: 2,
#           total_records: 150
#         }
#       }

#       expect(shared_storage).to receive(:write).with(first_page_record).ordered
#       expect(shared_storage).to receive(:write).with(second_page_record).ordered

#       bot.write
#     end

#     it 'does not write anything if content is empty' do
#       allow(bot).to receive(:process_response).and_return({ success: { type: 'github_pull_request', content: [] } })
#       expect(shared_storage).not_to receive(:write)
#       bot.write
#     end
#   end
# end
