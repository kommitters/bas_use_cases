# frozen_string_literal: true

# require 'spec_helper'
# require 'bas/shared_storage/postgres'
# require 'bas/utils/github/octokit_client'
# require 'ostruct'
# require_relative '../../../../src/implementations/fetch_issues_from_github'
# require_relative '../../../../src/utils/warehouse/github/issues_format'

# RSpec.describe Implementation::FetchIssuesFromGithub do
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

#   # Data Mocks
#   let(:repo1) { OpenStruct.new(full_name: 'fake-org/repo1') }
#   let(:issue1) { OpenStruct.new(id: 1, title: 'Test Issue 1', pull_request: nil) }
#   # Mocking a PR disguised as an Issue (GitHub API behavior)
#   let(:pr_as_issue) { OpenStruct.new(id: 99, title: 'I am a PR', pull_request: { url: 'http://...' }) }

#   let(:formatter) { instance_double(Utils::Warehouse::Github::IssuesFormatter) }

#   before do
#     allow(Utils::Github::OctokitClient).to receive(:new).and_return(octokit_client_wrapper)
#     allow(octokit_client_wrapper).to receive(:execute).and_return({ client: octokit_client })
#     allow(octokit_client).to receive(:auto_paginate=)

#     # Updated mock to accept pagination parameters
#     allow(octokit_client).to receive(:organization_repositories)
#       .with('fake-org', hash_including(page: 1, per_page: 100))
#       .and_return([repo1])

#     # Formatter setup
#     allow(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).and_return(formatter)
#     allow(formatter).to receive(:format).and_return({ normalized_issue: true })
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

#     context 'when fetching issues successfully' do
#       let(:last_response) { double('last_response', rels: { next: nil }) }
#       # Mock response specifically for the repo fetching loop to indicate "no next page"
#       let(:repo_response_no_next) { double('repo_response', rels: { next: nil }) }

#       before do
#         # Default behavior: repos have no next page, then issues have no next page
#         allow(octokit_client).to receive(:last_response).and_return(repo_response_no_next, last_response)
#       end

#       context 'on the first run (no last_run_timestamp)' do
#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           # Expectation: It should call without 'since'
#           allow(octokit_client).to receive(:issues)
#             .with('fake-org/repo1', hash_including(state: 'all', per_page: 100))
#             .and_return([issue1])
#         end

#         it 'fetches all issues and formats them' do
#           result = bot.process
#           expect(result).to have_key(:success)
#           expect(result.dig(:success, :type)).to eq('github_issue')
#           expect(result.dig(:success, :content)).to eq([{ normalized_issue: true }])
#         end
#       end

#       # New Context for Repository Pagination
#       context 'when repositories span multiple pages' do
#         let(:repo2) { OpenStruct.new(full_name: 'fake-org/repo2') }
#         let(:issue_repo1) { OpenStruct.new(id: 1, title: 'Issue Repo 1', pull_request: nil) }
#         let(:issue_repo2) { OpenStruct.new(id: 2, title: 'Issue Repo 2', pull_request: nil) }

#         # Mock responses for repo pagination logic
#         let(:repo_page1_resp) { double('resp_p1', rels: { next: true }) }
#         let(:repo_page2_resp) { double('resp_p2', rels: { next: nil }) }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           # 1. Mock fetch page 1 -> returns repo1
#           allow(octokit_client).to receive(:organization_repositories)
#             .with('fake-org', hash_including(page: 1))
#             .and_return([repo1])

#           # 2. Mock fetch page 2 -> returns repo2
#           allow(octokit_client).to receive(:organization_repositories)
#             .with('fake-org', hash_including(page: 2))
#             .and_return([repo2])

#           # 3. Control client.last_response for repository loop
#           allow(octokit_client).to receive(:last_response)
#             .and_return(repo_page1_resp, repo_page2_resp, last_response)

#           # 4. Mock issues calls for both repos
#           allow(octokit_client).to receive(:issues).with('fake-org/repo1', any_args).and_return([issue_repo1])
#           allow(octokit_client).to receive(:issues).with('fake-org/repo2', any_args).and_return([issue_repo2])
#         end

#         it 'iterates through repository pages and collects issues from all repos' do
#           result = bot.process
#           content = result.dig(:success, :content)
#           expect(content.size).to eq(2)

#           # Verify page 2 was requested
#           expect(octokit_client).to have_received(:organization_repositories)
#             .with('fake-org', hash_including(page: 2))
#         end
#       end

#       context 'on an incremental run (last_run_timestamp exists)' do
#         let(:timestamp) { Time.now - 3600 }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: timestamp))

#           # Expectation: It should call with 'since' parameter
#           allow(octokit_client).to receive(:issues)
#             .with('fake-org/repo1', hash_including(state: 'all', per_page: 100, since: timestamp.iso8601))
#             .and_return([issue1])
#         end

#         it 'fetches issues using the since parameter' do
#           result = bot.process
#           expect(result.dig(:success, :content)).not_to be_empty
#         end
#       end

#       context 'when the API returns Pull Requests mixed with Issues' do
#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           # Return both a real issue and a PR
#           allow(octokit_client).to receive(:issues)
#             .with('fake-org/repo1', any_args)
#             .and_return([issue1, pr_as_issue])
#         end

#         it 'filters out the pull requests and only processes valid issues' do
#           # Expect formatter to be called ONLY for issue1, NOT for pr_as_issue
#           expect(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).with(issue1, repo1)
#           expect(Utils::Warehouse::Github::IssuesFormatter).not_to receive(:new).with(pr_as_issue, repo1)

#           result = bot.process
#           content = result.dig(:success, :content)

#           expect(content.size).to eq(1)
#         end
#       end

#       context 'when pagination is required (inside a repo)' do
#         let(:issue2) { OpenStruct.new(id: 2, title: 'Test Issue 2', pull_request: nil) }

#         # Pagination Mocks for Issues
#         let(:page1_response) { double('page1_response', data: [issue1], rels: { next: page2_link }) }
#         let(:page2_link) { double('page2_link', get: page2_response) }
#         let(:page2_response) { double('page2_response', data: [issue2], rels: { next: nil }) }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           # First call returns page 1 logic
#           allow(octokit_client).to receive(:issues).and_return([issue1])

#           # Sequence:
#           # 1. organization_repositories -> repo_response_no_next (Stop repo loop)
#           # 2. issues -> page1_response (Continue issue loop)
#           allow(octokit_client).to receive(:last_response).and_return(repo_response_no_next, page1_response)

#           # Formatter allowance for both issues
#           allow(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).with(issue1, repo1).and_return(formatter)
#           allow(Utils::Warehouse::Github::IssuesFormatter).to receive(:new).with(issue2, repo1).and_return(formatter)
#         end

#         it 'fetches all pages and concatenates the results' do
#           result = bot.process
#           expect(result.dig(:success, :content).size).to eq(2)
#         end
#       end
#     end
#   end

#   describe '#write' do
#     let(:content) { Array.new(150) { { normalized_issue: true } } }
#     let(:process_response) { { success: { type: 'github_issue', content: content } } }

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
#           type: 'github_issue',
#           content: Array.new(100) { { normalized_issue: true } },
#           page_index: 1,
#           total_pages: 2,
#           total_records: 150
#         }
#       }

#       # The remaining 50 records
#       second_page_record = {
#         success: {
#           type: 'github_issue',
#           content: Array.new(50) { { normalized_issue: true } },
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
#       allow(bot).to receive(:process_response).and_return({ success: { type: 'github_issue', content: [] } })
#       expect(shared_storage).not_to receive(:write)
#       bot.write
#     end
#   end
# end
