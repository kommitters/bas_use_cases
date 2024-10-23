# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/pto_next_week/humanize_next_week_pto'

RSpec.describe UseCase::HumanizeNextWeekPto do
  before do
    @bot = UseCase::HumanizeNextWeekPto.new

    bas_bot = instance_double(Bot::HumanizePto)

    allow(Bot::HumanizePto).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
