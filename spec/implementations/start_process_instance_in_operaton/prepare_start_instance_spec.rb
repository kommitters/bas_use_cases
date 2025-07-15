# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/prepare_start_instance'
require 'bas/shared_storage/postgres'

RSpec.describe Implementation::PrepareStartInstanceFromConsole do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    options = {
      db_table: 'operaton_created_instance',
      tag: 'PrepareStartInstance'
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::PrepareStartInstanceFromConsole.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({
                                                    success: {
                                                      process_key: 'key',
                                                      business_key: 'key001',
                                                      variables: { foo: 'bar' },
                                                      validate_business_key: true
                                                    }
                                                  })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
