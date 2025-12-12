# frozen_string_literal: true

# require 'spec_helper'
# require 'bas/shared_storage/postgres'
# require 'bas/utils/github/octokit_client'
# require 'ostruct'
# require_relative '../../../../src/implementations/fetch_releases_from_github'
# require_relative '../../../../src/utils/warehouse/github/releases_format'

# RSpec.describe Implementation::FetchReleasesFromGithub do
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
#   let(:formatter) { instance_double(Utils::Warehouse::Github::ReleasesFormat) }

#   # Helper to mock a release object
#   def create_release(id, date_str)
#     OpenStruct.new(
#       id: id,
#       name: "Release #{id}",
#       published_at: Time.parse(date_str),
#       created_at: Time.parse(date_str)
#     )
#   end

#   before do
#     allow(Utils::Github::OctokitClient).to receive(:new).and_return(octokit_client_wrapper)
#     allow(octokit_client_wrapper).to receive(:execute).and_return({ client: octokit_client })
#     allow(octokit_client).to receive(:auto_paginate=)

#     allow(octokit_client).to receive(:organization_repositories)
#       .with('fake-org', hash_including(page: 1, per_page: 100))
#       .and_return([repo1])

#     # Formatter setup
#     allow(Utils::Warehouse::Github::ReleasesFormat).to receive(:new).and_return(formatter)
#     allow(formatter).to receive(:format).and_return({ normalized: true })
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

#     context 'when fetching releases successfully' do
#       let(:last_response) { double('last_response', rels: { next: nil }) }

#       before do
#         allow(octokit_client).to receive(:last_response).and_return(last_response)
#       end

#       context 'on the first run (no last_run_timestamp)' do
#         let(:release_new) { create_release(1, '2023-01-01T12:00:00Z') }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           allow(octokit_client).to receive(:releases)
#             .with('fake-org/repo1', per_page: 100)
#             .and_return([release_new])
#         end

#         it 'fetches all releases found' do
#           result = bot.process
#           expect(result).to have_key(:success)
#           content = result.dig(:success, :content)
#           expect(content.size).to eq(1)
#         end
#       end

#       context 'when repositories span multiple pages' do
#         let(:repo2) { OpenStruct.new(full_name: 'fake-org/repo2') }
#         let(:release_repo1) { create_release(1, '2023-01-01T12:00:00Z') }
#         let(:release_repo2) { create_release(2, '2023-01-01T12:00:00Z') }

#         # Mock responses for repo pagination logic
#         let(:repo_page1_resp) { double('resp_p1', rels: { next: true }) }
#         let(:repo_page2_resp) { double('resp_p2', rels: { next: nil }) }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           allow(octokit_client).to receive(:organization_repositories)
#             .with('fake-org', hash_including(page: 1))
#             .and_return([repo1])

#           allow(octokit_client).to receive(:organization_repositories)
#             .with('fake-org', hash_including(page: 2))
#             .and_return([repo2])

#           allow(octokit_client).to receive(:last_response)
#             .and_return(repo_page1_resp, repo_page2_resp, last_response)

#           allow(octokit_client).to receive(:releases).with('fake-org/repo1', any_args).and_return([release_repo1])
#           allow(octokit_client).to receive(:releases).with('fake-org/repo2', any_args).and_return([release_repo2])
#         end

#         it 'iterates through repository pages and collects releases from all repos' do
#           result = bot.process
#           content = result.dig(:success, :content)

#           expect(content.size).to eq(2)

#           expect(octokit_client).to have_received(:organization_repositories)
#             .with('fake-org', hash_including(page: 2))
#         end
#       end

#       context 'on an incremental run (last_run_timestamp exists)' do
#         let(:last_run_time) { Time.parse('2023-06-01T00:00:00Z') }

#         # Release newer than last run
#         let(:new_release) { create_release(100, '2023-06-02T12:00:00Z') }
#         # Release older than last run
#         let(:old_release) { create_release(99, '2023-05-30T12:00:00Z') }

#         before do
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: last_run_time))

#           # Return mixed data: one new, one old
#           allow(octokit_client).to receive(:releases)
#             .with('fake-org/repo1', per_page: 100)
#             .and_return([new_release, old_release])
#         end

#         it 'filters out releases older than the last run' do
#           result = bot.process
#           content = result.dig(:success, :content)

#           # Should only contain the new release
#           expect(content.size).to eq(1)
#         end
#       end

#       context 'when pagination is required (inside a repo)' do
#         let(:release_page1) { create_release(1, '2023-02-01T00:00:00Z') }
#         let(:release_page2) { create_release(2, '2023-01-01T00:00:00Z') }

#         # Pagination Mocks
#         let(:page1_response) { double('page1_response', data: [release_page1], rels: { next: page2_link }) }
#         let(:page2_link) { double('page2_link', get: page2_response) }
#         let(:page2_response) { double('page2_response', data: [release_page2], rels: { next: nil }) }

#         let(:repo_response_no_next) { double('repo_response', rels: { next: nil }) }
#         before do
#           # Full sync scenario
#           allow(shared_storage).to receive(:read).and_return(OpenStruct.new(inserted_at: nil))

#           # Initial call
#           allow(octokit_client).to receive(:releases).and_return([release_page1])

#           # Pagination chain
#           allow(octokit_client).to receive(:last_response).and_return(repo_response_no_next, page1_response)
#         end

#         it 'iterates through pages and collects all releases' do
#           result = bot.process
#           content = result.dig(:success, :content)
#           expect(content.size).to eq(2)
#         end
#       end
#     end
#   end

#   describe '#write' do
#     let(:content) { Array.new(150) { { normalized: true } } }
#     let(:process_response) { { success: { type: 'github_release', content: content } } }

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
#           type: 'github_release',
#           content: Array.new(100) { { normalized: true } },
#           page_index: 1,
#           total_pages: 2,
#           total_records: 150
#         }
#       }

#       second_page_record = {
#         success: {
#           type: 'github_release',
#           content: Array.new(50) { { normalized: true } },
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
#       allow(bot).to receive(:process_response).and_return({ success: { type: 'github_release', content: [] } })
#       expect(shared_storage).not_to receive(:write)
#       bot.write
#     end
#   end
# end
