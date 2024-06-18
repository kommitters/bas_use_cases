# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases/birthday/fetch_birthday_from_notion'

ENV['BIRTHDAY_NOTION_DATABASE_ID'] = 'BIRTHDAY_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['BIRTHDAY_TABLE'] = 'BIRTHDAY_TABLE'
ENV['DB_HOST'] = 'DB_HOST'
ENV['DB_PORT'] = 'DB_PORT'
ENV['POSTGRES_DB'] = 'POSTGRES_DB'
ENV['POSTGRES_USER'] = 'POSTGRES_USER'
ENV['POSTGRES_PASSWORD'] = 'POSTGRES_PASSWORD'

RSpec.describe Fetch::BirthdayFromNotion do
  before do
    params = {
      notion_database_id: ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID'),
      notion_secret: ENV.fetch('NOTION_SECRET'),
      table_name: ENV.fetch('BIRTHDAY_TABLE'),
      db_host: ENV.fetch('DB_HOST'),
      db_port: ENV.fetch('DB_PORT'),
      db_name: ENV.fetch('POSTGRES_DB'),
      db_user: ENV.fetch('POSTGRES_USER'),
      db_password: ENV.fetch('POSTGRES_PASSWORD')
    }

    @bot = Fetch::BirthdayFromNotion.new(params)
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
