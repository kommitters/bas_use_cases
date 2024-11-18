# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/implementations/fetch_next_week_pto_from_notion'

ENV['PTO_NOTION_DATABASE_ID'] = 'PTO_NOTION_DATABASE_ID'
ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['PTO_TABLE'] = 'PTO_TABLE'

RSpec.describe Bot::FetchNextWeekPtosFromNotion do

  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  
  before do
    options = {
      database_id: ENV.fetch('PTO_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }


    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: { key: 'value' }, inserted_at: Time.now)
    )

    allow(mocked_shared_storage_writer).to receive(:write).and_return(
      [{ 'status' => 'success', 'id' => 1 }]
    )

    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)

    @bot = Bot::FetchNextWeekPtosFromNotion.new(options, mocked_shared_storage_reader, mocked_shared_storage_writer)
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
