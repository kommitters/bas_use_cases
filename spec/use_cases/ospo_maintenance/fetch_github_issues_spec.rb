# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/fetch_github_issues'

ENV['OSPO_MAINTENANCE_SECRET'] = 'OSPO_MAINTENANCE_SECRET'
ENV['OSPO_MAINTENANCE_APP_ID'] = 'OSPO_MAINTENANCE_APP_ID'
ENV['OSPO_MAINTENANCE_TABLE'] = 'OSPO_MAINTENANCE_TABLE'
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
}.freeze

RSpec.describe Bot::FetchGithubIssues do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do

    options = {
      private_pem: 'PRIVATE_PEM',
      app_id: '12345',
      repo: 'kommitters/bas',
      filters: { state: 'all' },
      organization: 'kommitters',
      domain: 'kommitters',
      status: 'Backlog',
      work_item_type: 'activity',
      type_id: 'ecc3b2bcc3c941d29e3499721c063dd6',
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

    @bot = Bot::FetchGithubIssues.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchGithubIssues)

      allow(Bot::FetchGithubIssues).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
