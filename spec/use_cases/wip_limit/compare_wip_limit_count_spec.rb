# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/wip_limit/compare_wip_limit_count'

ENV['WIP_TABLE'] = 'WIP_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['DB_NAME'] = 'DB_NAME'
ENV['DB_USER'] = 'DB_USER'
ENV['DB_PASSWORD'] = 'DB_PASSWORD'

RSpec.describe Compare::WipLimitCount do
  before do
    params = {
      table_name: ENV.fetch('WIP_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('DB_NAME'),
      db_user: ENV.fetch('DB_USER'),
      db_password: ENV.fetch('DB_PASSWORD')
    }

    @bot = Compare::WipLimitCount.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::CompareWipLimitCount)

      allow(Bot::CompareWipLimitCount).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
