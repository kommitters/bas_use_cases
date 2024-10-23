# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/wip_limit/fetch_domains_wip_limit'

RSpec.describe UseCase::FetchDomainsWipLimitFromNotion do
  before do
    @bot = UseCase::FetchDomainsWipLimitFromNotion.new

    bas_bot = instance_double(Bot::FetchDomainsWipLimitFromNotion)

    allow(Bot::FetchDomainsWipLimitFromNotion).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
