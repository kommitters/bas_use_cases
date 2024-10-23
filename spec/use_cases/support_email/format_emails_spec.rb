# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/support_email/format_emails'

RSpec.describe UseCase::FormatEmailsFromImap do
  before do
    @bot = UseCase::FormatEmailsFromImap.new

    bas_bot = instance_double(Bot::FormatEmails)

    allow(Bot::FormatEmails).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
