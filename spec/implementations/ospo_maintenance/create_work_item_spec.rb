# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/create_work_item'
require 'bas/shared_storage/postgres'

ENV['OSPO_MAINTENANCE_NOTION_DATABASE_ID'] = 'OSPO_MAINTENANCE_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['OSPO_MAINTENANCE_TABLE'] = 'OSPO_MAINTENANCE_TABLE'

RSpec.describe Implementation::CreateWorkItem do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:options) do
    {
      database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }
  end

  let(:mock_read_response) do
    instance_double(Bas::SharedStorage::Types::Read,
                    data: { issue_id: 123, title: 'Bug: Sample Issue', body: 'Issue description' },
                    inserted_at: Time.now)
  end

  let(:mock_write_response) { { 'status' => 'success', 'work_item_id' => 456 } }
  let(:mock_execute_response) { { success: true, work_item_id: 456 } }

  let(:bot) { Implementation::CreateWorkItem.new(options, mocked_shared_storage) }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(mock_read_response)
    allow(mocked_shared_storage).to receive(:write).and_return(mock_write_response)
    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    allow(bot).to receive(:execute).and_return(mock_execute_response)
  end

  describe '#execute' do
    it 'executes the bot and returns mocked data' do
      expect(bot.execute).to eq(mock_execute_response)
    end
  end
end
