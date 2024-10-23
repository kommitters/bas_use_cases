# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/digital_ocean_bill_alert/fetch_billing_from_digital_ocean'

RSpec.describe UseCase::FetchBillingFromDigitalOcean do
  before do
    @bot = UseCase::FetchBillingFromDigitalOcean.new
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
