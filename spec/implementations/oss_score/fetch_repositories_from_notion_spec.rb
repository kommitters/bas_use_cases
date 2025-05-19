# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/implementations/fetch_repositories_from_notion'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/types/read'

ENV['NOTION_SECRET'] = 'NOTION_SECRET'
ENV['OSS_NOTION_DATABASE_ID'] = 'OSS_NOTION_DATABASE_ID'

RSpec.describe Implementation::FetchRepositoriesFromNotion do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }

  let(:options) do
    {
      database_id: ENV['OSS_NOTION_DATABASE_ID'],
      secret: ENV['NOTION_SECRET']
    }
  end

  before do
    allow(mocked_shared_storage_writer).to receive(:write).and_return([{ 'status' => 'success', 'id' => 1 }])
    allow(mocked_shared_storage_writer).to receive(:set_processed)
    allow(mocked_shared_storage_writer).to receive(:update_stage)
    allow(mocked_shared_storage_writer).to receive(:set_in_process)

    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, id: 1, data: {}, inserted_at: Time.now)
    )
    allow(mocked_shared_storage_reader).to receive(:set_processed)
    allow(mocked_shared_storage_reader).to receive(:set_in_process)

    @bot = Implementation::FetchRepositoriesFromNotion.new(options, mocked_shared_storage_reader,
                                                           mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FetchRepositoriesFromNotion)

      allow(Implementation::FetchRepositoriesFromNotion).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return({ success: true })
    end

    it 'should execute the bas bot' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
