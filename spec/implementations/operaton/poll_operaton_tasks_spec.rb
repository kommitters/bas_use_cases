# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/poll_operaton_tasks'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

RSpec.describe Implementation::PollOperatonTasks do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }

  let(:task_data) do
    {
      'id' => '12345678-task-id',
      'topicName' => 'send_email',
      'workerId' => 'test_worker',
      'someOtherField' => 'value'
    }
  end

  let(:fake_client) { instance_double(Utils::Operaton::ExternalTaskClient) }

  before do
    options = {
      operaton_base_url: 'http://localhost:8080/engine-rest',
      worker_id: 'test_worker',
      topics: 'send_email'
    }

    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage_writer).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)

    allow(Utils::Operaton::ExternalTaskClient).to receive(:new).and_return(fake_client)
    allow(fake_client).to receive(:fetch_and_lock).and_return([task_data])

    @bot = Implementation::PollOperatonTasks.new(options, mocked_shared_storage_reader, mocked_shared_storage_writer)
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
