# frozen_string_literal: true

require_relative '../../../src/use_case/birthday/fetch_birthday_from_notion'

RSpec.describe UseCase::FetchBirthdayFromNotion do
  before do
    @bot = UseCase::FetchBirthdayFromNotion.new
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchBirthdaysFromNotion)

      allow(Bot::FetchBirthdaysFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
