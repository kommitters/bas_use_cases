# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/wip_limit/notify_domains_wip_limit_exceeded'

ENV['WIP_LIMIT_DISCORD_WEBHOOK'] = 'WIP_LIMIT_DISCORD_WEBHOOK'
ENV['DISCORD_BOT_NAME'] = 'DISCORD_BOT_NAME'
ENV['WIP_TABLE'] = 'WIP_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe UseCase::NotifyDomainsWipLimitExceeded do
  before do
    @bot = UseCase::NotifyDomainsWipLimitExceeded.new

    bas_bot = instance_double(Bot::NotifyDiscord)

    allow(Bot::NotifyDiscord).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
