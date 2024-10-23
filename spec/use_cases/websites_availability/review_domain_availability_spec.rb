# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/websites_availability/review_domain_availability'

RSpec.describe UseCase::ReviewDomainAvailability do
  before do
    @bot = UseCase::ReviewDomainAvailability.new

    bas_bot = instance_double(Bot::ReviewDomainAvailability)

    allow(Bot::ReviewDomainAvailability).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
