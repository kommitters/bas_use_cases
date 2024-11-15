# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/garbage_collector'

RSpec.describe Bot::GarbageCollector do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    options = {
      connection: 'test_connection',
      db_table: 'test_table'
    }

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Bot::GarbageCollector.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: { archived: true } })

      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot and return success' do
      result = @bot.execute
      expect(result).to eq({ success: true })
    end
  end
end
