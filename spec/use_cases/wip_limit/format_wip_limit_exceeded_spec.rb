# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/wip_limit/format_wip_limit_exceeded'

RSpec.describe UseCase::FormatWipLimitExceeded do
  before do
    @bot = UseCase::FormatWipLimitExceeded.new

    bas_bot = instance_double(Bot::FormatWipLimitExceeded)

    allow(Bot::FormatWipLimitExceeded).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
