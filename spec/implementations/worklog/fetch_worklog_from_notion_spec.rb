# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/fetch_worklog_from_notion'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/types/read'

ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['WORKLOG_NOTION_DATABASE_ID'] = 'WORKLOG_NOTION_DATABASE_ID'
ENV['WORKLOG_TABLE'] = 'WORKLOG_TABLE'

RSpec.describe Implementation::FetchWorklogsFromNotion do
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
      database_id: ENV.fetch('WORKLOG_NOTION_DATABASE_ID'),
      secret: ENV.fetch('NOTION_SECRET')
    }

    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::FetchWorklogsFromNotion.new(options, mocked_shared_storage_reader,
                                                       mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FetchWorklogsFromNotion)

      allow(Implementation::FetchWorklogsFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
