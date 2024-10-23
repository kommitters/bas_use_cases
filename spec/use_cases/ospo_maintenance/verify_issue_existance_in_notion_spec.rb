# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_case/ospo_maintenance/verify_issue_existance_in_notion'

RSpec.describe UseCase::VerifyIssueExistanceInNotion do
  before do
    @bot = UseCase::VerifyIssueExistanceInNotion.new

    bas_bot = instance_double(Bot::VerifyIssueExistanceInNotion)

    allow(Bot::VerifyIssueExistanceInNotion).to receive(:new).and_return(bas_bot)
    allow(bas_bot).to receive(:execute).and_return({})
  end

  context '.execute' do
    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
