# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/default'
require 'bas/shared_storage/elasticsearch'
require_relative '../../../src/implementations/elasticsearch_garbage_collector'

RSpec.describe Implementation::ElasticsearchGarbageCollector do
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Elasticsearch) }

  before do
    allow(mocked_shared_storage_reader).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: { key: 'value' }, inserted_at: Time.now)
    )
    allow(mocked_shared_storage_writer).to receive(:write).and_return({ 'status' => 'success' })

    options = {
      connection: 'test_connection',
      index: 'test_index'
    }

    allow(mocked_shared_storage_reader).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_reader).to receive(:set_in_process).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage_writer).to receive(:set_in_process).and_return(nil)

    @bot = Implementation::ElasticsearchGarbageCollector.new(options, mocked_shared_storage_reader,
                                                             mocked_shared_storage_writer)
  end

  context '.execute' do
    before do
      allow(@bot).to receive(:process).and_return({ success: { archived: true } })
    end

    it 'should execute the bas bot and return success' do
      result = @bot.execute
      expect(result).to eq({ 'status' => 'success' })
    end
  end
end
