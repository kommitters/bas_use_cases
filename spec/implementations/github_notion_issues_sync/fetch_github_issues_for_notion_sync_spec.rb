# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/fetch_github_issues_for_notion_sync'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

ENV['GITHUB_TOKEN'] = 'GITHUB_TOKEN'
ENV['REPO_IDENTIFIER'] = 'owner/repo'

RSpec.describe Implementation::FetchGithubIssuesForNotionSync do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  before do
    options = {
      repo_identifier: ENV.fetch('REPO_IDENTIFIER'),
      GITHUB_TOKEN: ENV.fetch('GITHUB_TOKEN')
    }

    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage_writer).to receive(:write).and_return(
      { success: [{ html_url: 'www.sample.com', title: 'Test issue' }] }
    )

    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::FetchGithubIssuesForNotionSync.new(options, mocked_shared_storage_reader,
                                                              mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FetchGithubIssuesForNotionSync)

      allow(Implementation::FetchGithubIssuesForNotionSync).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      result = @bot.execute
      expect(result).not_to be_nil
      expect(result[:success]).to be_an(Array)
      expect(result[:success].first).to have_key(:html_url)
      expect(result[:success].first).to have_key(:title)
    end
  end
end
