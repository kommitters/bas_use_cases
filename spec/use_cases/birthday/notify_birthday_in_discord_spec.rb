# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/birthday/notify_birthday_in_discord'

RSpec.describe UseCase::NotifyBirthdayInDiscord do
  before do
    @bot = UseCase::NotifyBirthdayInDiscord.new
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::NotifyDiscord)

      allow(Bot::NotifyDiscord).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
