# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/types/read'

require_relative '../../../src/implementations/compare_wip_limit_count'

RSpec.describe Implementation::CompareWipLimitCount do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: {
                        'domains_limits' => { 'domain1' => 10, 'domain2' => 5 },
                        'domain_wip_count' => { 'domain1' => 15, 'domain2' => 3 }
                      }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    allow(mocked_shared_storage).to receive(:read_response).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }.to_json, inserted_at: Time.now)
    )

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::CompareWipLimitCount.new({}, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::CompareWipLimitCount)

      allow(Implementation::CompareWipLimitCount).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
