# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/fetch_billing_from_digital_ocean'

ENV['DIGITAL_OCEAN_SECRET'] = 'DIGITAL_OCEAN_SECRET'
ENV['DO_TABLE'] = 'DO_TABLE'

RSpec.describe Bot::FetchBillingFromDigitalOcean do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do
    options = {
      secret: ENV.fetch('DIGITAL_OCEAN_SECRET')
    }

    @bot = Bot::FetchBillingFromDigitalOcean.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchBillingFromDigitalOcean)

      allow(Bot::FetchBillingFromDigitalOcean).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
