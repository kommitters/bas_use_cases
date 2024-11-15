# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/fetch_next_week_birthday_from_notion'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'

ENV['BIRTHDAY_NOTION_DATABASE_ID'] = 'BIRTHDAY_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['BIRTHDAY_TABLE'] = 'BIRTHDAY_TABLE'

RSpec.describe Bot::FetchNextWeekBirthdaysFromNotion do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  before do
    options = {
      database_id: ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }


    @bot = Bot::FetchNextWeekBirthdaysFromNotion.new(options, mocked_shared_storage_reader,
                                                     mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchNextWeekBirthdaysFromNotion)

      allow(Bot::FetchNextWeekBirthdaysFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
