# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/update_work_item'

ENV['OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID'] = 'OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['OSPO_MAINTENANCE_TABLE'] = 'OSPO_MAINTENANCE_TABLE'

RSpec.describe Bot::UpdateWorkItem do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do
    options = {
      users_database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_USERS_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Bot::UpdateWorkItem.new(options, mocked_shared_storage)
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
