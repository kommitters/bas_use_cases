# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/digital_ocean_bill_alert/format_do_bill_alert'

RSpec.describe UseCase::FormatDoBillAlert do
  before do
    @bot = UseCase::FormatDoBillAlert.new
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
