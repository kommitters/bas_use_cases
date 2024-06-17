# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/pto_next_week/humanize_next_week_pto'

ENV['OPENAI_SECRET'] = 'OPENAI_SECRET'
ENV['NEXT_WEEK_PTO_OPENAI_ASSISTANT'] = 'NEXT_WEEK_PTO_OPENAI_ASSISTANT'
ENV['BIRTHDAY_TABLE'] = 'PTO_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['DB_NAME'] = 'DB_NAME'
ENV['DB_USER'] = 'DB_USER'
ENV['DB_PASSWORD'] = 'DB_PASSWORD'

RSpec.describe Humanize::NextWeekPto do
  before do
    params = {
      openai_secret: ENV.fetch('OPENAI_SECRET'),
      openai_assistant: ENV.fetch('NEXT_WEEK_PTO_OPENAI_ASSISTANT'),
      table_name: ENV.fetch('PTO_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('DB_NAME'),
      db_user: ENV.fetch('DB_USER'),
      db_password: ENV.fetch('DB_PASSWORD')
    }

    @bot = Humanize::NextWeekPto.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::HumanizePto)

      allow(Bot::HumanizePto).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
