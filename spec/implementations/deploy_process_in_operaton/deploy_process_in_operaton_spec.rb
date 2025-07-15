# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/deploy_process_in_operaton'
require 'bas/shared_storage/postgres'

RSpec.describe Implementation::DeployProcess do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    options = {
      operaton_base_url: 'http://localhost:8080/engine-rest',
      db_table: 'operaton_process_deployed',
      tag: 'DeployProcess'
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(
        Bas::SharedStorage::Types::Read,
        data: { file_path: 'path/to/diagram.bpmn', deployment_name: 'MyDeployment' },
        inserted_at: Time.now
      )
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::DeployProcess.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: { id: 'deployment-id-123' } })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
