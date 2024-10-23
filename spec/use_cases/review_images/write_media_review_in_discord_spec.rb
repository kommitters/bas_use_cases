# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/review_images/write_media_review_in_discord'

RSpec.describe UseCase::WriteMediaReviewInDiscord do
  before do
    @bot = UseCase::WriteMediaReviewInDiscord.new

    bas_bot = instance_double(Bot::WriteMediaReviewInDiscord)

    allow(Bot::WriteMediaReviewInDiscord).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
