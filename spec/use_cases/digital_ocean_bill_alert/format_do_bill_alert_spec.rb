# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/format_do_bill_alert'
require 'bas/shared_storage/postgres'

ENV['DIGITAL_OCEAN_THRESHOLD'] = 'DIGITAL_OCEAN_THRESHOLD'
ENV['DO_TABLE'] = 'DO_TABLE'

RSpec.describe Bot::FormatDoBillAlert do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  before do
    options = {
      threshold: ENV.fetch('DIGITAL_OCEAN_THRESHOLD').to_f
    }

    @bot = Bot::FormatDoBillAlert.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FormatDoBillAlert)

      allow(Bot::FormatDoBillAlert).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
