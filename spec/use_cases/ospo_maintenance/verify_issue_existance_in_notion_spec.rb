# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/ospo_maintenance/verify_issue_existance_in_notion'

ENV['OSPO_MAINTENANCE_NOTION_DATABASE_ID'] = 'OSPO_MAINTENANCE_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['OSPO_MAINTENANCE_TABLE'] = 'OSPO_MAINTENANCE_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Verify::IssueExistanceInNotion do
  before do
    params = {
      database_id: ENV.fetch('OSPO_MAINTENANCE_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET'),
      table_name: ENV.fetch('OSPO_MAINTENANCE_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Verify::IssueExistanceInNotion.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::VerifyIssueExistanceInNotion)

      allow(Bot::VerifyIssueExistanceInNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
