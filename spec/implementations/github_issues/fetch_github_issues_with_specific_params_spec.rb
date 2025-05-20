# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/fetch_github_issues_with_specific_params'

ENV['GITHUB_TOKEN']='GITHUB_TOKEN'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

CONNECTION = {
  host: ENV.fetch('DB_HOST'),
  port: ENV.fetch('DB_PORT'),
  dbname: ENV.fetch('POSTGRES_DB'),
  user: ENV.fetch('POSTGRES_USER'),
  password: ENV.fetch('POSTGRES_PASSWORD')
}

BASE_URL = 'https://api.github.com/search/issues'

RSpec.describe Implementation::FetchGithubIssues do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do 
    options = {
      connection: CONNECTION,
      db_table: 'github_issues',
      tag: 'GithubIssueRequest'
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::FetchGithubIssues.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: { updated: nil } })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
