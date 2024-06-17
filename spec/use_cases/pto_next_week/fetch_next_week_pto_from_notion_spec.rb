# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/pto_next_week/fetch_next_week_pto_from_notion'

ENV['PTO_NOTION_DATABASE_ID'] = 'PTO_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['PTO_TABLE'] = 'PTO_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['DB_NAME'] = 'DB_NAME'
ENV['DB_USER'] = 'DB_USER'
ENV['DB_PASSWORD'] = 'DB_PASSWORD'

RSpec.describe Fetch::NextWeekPtoFromNotion do
  before do
    params = {
      notion_database_id: ENV.fetch('PTO_NOTION_DATABASE_ID'),
      notion_secret: ENV.fetch('NOTION_SECRET'),
      table_name: ENV.fetch('PTO_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('DB_NAME'),
      db_user: ENV.fetch('DB_USER'),
      db_password: ENV.fetch('DB_PASSWORD')
    }

    @bot = Fetch::NextWeekPtoFromNotion.new(params)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchNextWeekPtosFromNotion)

      allow(Bot::FetchNextWeekPtosFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({})
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
