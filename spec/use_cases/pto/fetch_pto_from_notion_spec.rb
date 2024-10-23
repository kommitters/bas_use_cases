# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/pto/fetch_pto_from_notion'

RSpec.describe UseCase::FetchPtoFromNotion do
  before do
    @bot = UseCase::FetchPtoFromNotion.new

    bas_bot = instance_double(Bot::FetchPtosFromNotion)

    allow(Bot::FetchPtosFromNotion).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
