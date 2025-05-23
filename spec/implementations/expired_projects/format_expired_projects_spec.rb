# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/format_expired_projects'

RSpec.describe Implementation::FormatExpiredProjects do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:read_data) { { 'projects_expired' => [{ 'name' => 'Project A', 'expiration_date' => '2024-11-15' }] } }

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data)
    )
    allow(mocked_shared_storage).to receive(:write).and_return(
      { 'status' => 'success', 'id' => 1 }
    )

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    options = {
      template: 'The project <name> expired on <expiration_date>.'
    }

    @bot = Implementation::FormatExpiredProjects.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FormatExpiredProjects)

      allow(Implementation::FormatExpiredProjects).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return(
        { success: { notification: 'The project Project A expired on 2024-11-15.' } }
      )
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
