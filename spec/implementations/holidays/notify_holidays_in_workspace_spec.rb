# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/notify_workspace'
require 'bas/shared_storage/elasticsearch'

ENV['GOOGLE_CHAT_WEBHOOK_HOLIDAYS'] = 'GOOGLE_CHAT_WEBHOOK_HOLIDAYS'

RSpec.describe Implementation::NotifyWorkspace do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Elasticsearch) }
  before do
    options = {
      webhook: ENV.fetch('GOOGLE_CHAT_WEBHOOK_HOLIDAYS')
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::NotifyWorkspace.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: {} })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
