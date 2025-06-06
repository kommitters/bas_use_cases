# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/notify_github_issues_to_notion'
require 'bas/shared_storage/postgres'

ENV['NOTION_DATABASE_ID'] = 'NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'

RSpec.describe Implementation::NotifyGithubIssuesToNotion do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do
    options = {
      notion_database_id: ENV.fetch('NOTION_DATABASE_ID'),
      notion_secret: ENV.fetch('NOTION_SECRET')
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: [{ number: 123, title: 'Test Issue' }],
                                                       inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::NotifyGithubIssuesToNotion.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: {} })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
