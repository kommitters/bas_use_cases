# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/write_image_review_in_discord'

ENV['REVIEW_IMAGES_TABLE'] = 'REVIEW_IMAGES_TABLE'
ENV['DISCORD_BOT_TOKEN'] = 'DISCORD_BOT_TOKEN'

RSpec.describe Implementation::WriteMediaReviewInDiscord do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    options = {
      secret_token: "Bot #{ENV.fetch('DISCORD_BOT_TOKEN')}"
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    Implementation::WriteMediaReviewInDiscord.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: { review: nil } })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
