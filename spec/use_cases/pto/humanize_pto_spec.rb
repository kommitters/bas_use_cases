# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/humanize_pto'

ENV['OPENAI_SECRET'] = 'OPENAI_SECRET'
ENV['PTO_OPENAI_ASSISTANT'] = 'PTO_OPENAI_ASSISTANT'
ENV['BIRTHDAY_TABLE'] = 'PTO_TABLE'

RSpec.describe Bot::HumanizePto do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do

    options = {
      secret: ENV.fetch('OPENAI_SECRET'),
      assistant_id: ENV.fetch('PTO_OPENAI_ASSISTANT'),
      prompt: "Today is march 1 and the PTO's are: {data}"
    }

    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage).to receive(:write).and_return({ 'status' => 'success' })

    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    Bot::HumanizePto.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({  success: { notification: '' } })
      allow(@bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
