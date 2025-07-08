# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/process_send_email_task'
require 'bas/shared_storage/postgres'

RSpec.describe Implementation::ProcessSendEmailTask do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    options = {}

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::ProcessSendEmailTask.new(options, mocked_shared_storage)
  end

  context '.execute' do
    it 'should execute the bas bot and use shared storage' do
      result = @bot.execute

      expect(result).not_to be_nil
      expect(mocked_shared_storage).to have_received(:read)
      expect(mocked_shared_storage).to have_received(:write)
    end
  end
end
