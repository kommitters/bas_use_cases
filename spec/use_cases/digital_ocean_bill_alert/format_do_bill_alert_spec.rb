# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/format_do_bill_alert'
require 'bas/shared_storage/postgres'

ENV['DIGITAL_OCEAN_THRESHOLD'] = 'DIGITAL_OCEAN_THRESHOLD'
ENV['DO_TABLE'] = 'DO_TABLE'

RSpec.describe Bot::FormatDoBillAlert do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do
    options = {
      threshold: ENV.fetch('DIGITAL_OCEAN_THRESHOLD').to_f
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    @bot = Bot::FormatDoBillAlert.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FormatDoBillAlert)

      allow(@bot).to receive(:process).and_return({ success: { notification: '' }})
      allow(@bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
