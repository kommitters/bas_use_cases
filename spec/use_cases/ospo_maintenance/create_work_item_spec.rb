# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/ospo_maintenance/create_work_item'

RSpec.describe UseCase::CreateWorkItem do
  before do
    @bot = UseCase::CreateWorkItem.new

    bas_bot = instance_double(Bot::CreateWorkItem)

    allow(Bot::CreateWorkItem).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
