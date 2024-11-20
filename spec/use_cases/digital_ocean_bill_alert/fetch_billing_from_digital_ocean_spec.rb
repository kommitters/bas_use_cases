# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/fetch_billing_from_digital_ocean'

ENV['DIGITAL_OCEAN_SECRET'] = 'DIGITAL_OCEAN_SECRET'
ENV['DO_TABLE'] = 'DO_TABLE'

RSpec.describe Implementation::FetchBillingFromDigitalOcean do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do
    options = {
      secret: ENV.fetch('DIGITAL_OCEAN_SECRET')
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::FetchBillingFromDigitalOcean.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FetchBillingFromDigitalOcean)

      allow(Implementation::FetchBillingFromDigitalOcean).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
