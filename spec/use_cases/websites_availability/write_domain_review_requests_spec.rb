# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/websites_availability/write_domain_review_requests'

RSpec.describe UseCase::WriteDomainReviewRequests do
  before do
    @bot = UseCase::WriteDomainReviewRequests.new

    bas_bot = instance_double(Bot::WriteDomainReviewRequests)

    allow(Bot::WriteDomainReviewRequests).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
