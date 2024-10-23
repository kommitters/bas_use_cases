# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/wip_limit/fetch_domains_wip_count'

RSpec.describe UseCase::FetchDomainsWipCountFromNotion do
  before do
    @bot = UseCase::FetchDomainsWipCountFromNotion.new

    bas_bot = instance_double(Bot::FetchDomainsWipCountsFromNotion)

    allow(Bot::FetchDomainsWipCountsFromNotion).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
