# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/wip_limit/compare_wip_limit_count'

RSpec.describe UseCase::CompareWipLimitCount do
  before do
    @bot = UseCase::CompareWipLimitCount.new

    bas_bot = instance_double(Bot::CompareWipLimitCount)

    allow(Bot::CompareWipLimitCount).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
