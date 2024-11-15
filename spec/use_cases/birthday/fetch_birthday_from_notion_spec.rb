# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/fetch_birthday_from_notion'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/types/read'

ENV['BIRTHDAY_NOTION_DATABASE_ID'] = 'BIRTHDAY_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['BIRTHDAY_TABLE'] = 'BIRTHDAY_TABLE'

RSpec.describe Bot::FetchBirthdaysFromNotion do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }

  before do
    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage_writer).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    options = {
      database_id: ENV.fetch('BIRTHDAY_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }

    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)

    @bot = Bot::FetchBirthdaysFromNotion.new(options, mocked_shared_storage_reader, mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Bot::FetchBirthdaysFromNotion)

      allow(Bot::FetchBirthdaysFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
