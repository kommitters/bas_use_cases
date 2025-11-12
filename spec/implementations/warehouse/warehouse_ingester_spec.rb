# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/warehouse_ingester'

RSpec.describe Implementation::WarehouseIngester do
  let(:options) { { db: :fake_connection } }
  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:subject) { described_class.new(options, shared_storage) }

  let(:service) { instance_double(Services::Postgres::Okr) }
  let(:records) { [{ 'external_okr_id' => 'okr-1', 'code' => 'TEST-1' }] }
  let(:mock_response) do
    double('SharedStorageResponse',
           data: { 'type' => 'okr', 'content' => records })
  end

  before(:each) do
    stub_const('BAS_LOGGER', instance_double(BasLogger, info: nil, warn: nil, error: nil))

    allow(subject).to receive(:unprocessable_response).and_return(false)

    allow(subject).to receive(:read_response).and_return(mock_response)

    allow(Services::Postgres::Okr).to receive(:new).with(:fake_connection).and_return(service)

    allow(service).to receive(:query)
    allow(service).to receive(:insert)
    allow(service).to receive(:update)
  end

  describe '#process' do
    context 'when an entity is new' do
      it 'queries for the entity, inserts it, and logs success' do
        allow(service).to receive(:query).with({ external_okr_id: 'okr-1' }).and_return([])

        subject.process

        expect(service).to have_received(:insert).with(hash_including('external_okr_id' => 'okr-1')).once
        expect(service).not_to have_received(:update)

        expect(BAS_LOGGER).to have_received(:info).with(hash_including(
                                                          message: 'Ingestion complete. Processed 1 items.'
                                                        )).once
      end
    end

    context 'when an entity already exists' do
      it 'queries for the entity, updates it, and logs success' do
        allow(service).to receive(:query).with({ external_okr_id: 'okr-1' }).and_return([{ id: 10 }])

        subject.process

        expect(service).to have_received(:update).with(10, hash_including('external_okr_id' => 'okr-1')).once
        expect(service).not_to have_received(:insert)

        expect(BAS_LOGGER).to have_received(:info).with(hash_including(
                                                          message: 'Ingestion complete. Processed 1 items.'
                                                        )).once
      end
    end

    context 'when a record is missing its external ID' do
      let(:records) { [{ 'name' => 'Invalid Record' }] }

      it 'does not query, insert, update, and logs 0 processed' do
        subject.process

        expect(service).not_to have_received(:query)
        expect(service).not_to have_received(:insert)
        expect(service).not_to have_received(:update)

        expect(BAS_LOGGER).to have_received(:info).with(hash_including(
                                                          message: 'Ingestion complete. Processed 0 items.'
                                                        )).once
      end
    end

    context 'with edge cases' do
      context 'when the content array is empty' do
        let(:records) { [] }

        it 'returns zero processed, logs 0, and does not call any service methods' do
          result = subject.process

          expect(result).to eq({ success: { processed: 0 } })
          expect(service).not_to have_received(:query)

          expect(BAS_LOGGER).to have_received(:info).with(hash_including(
                                                            message: 'Ingestion complete. Processed 0 items.'
                                                          )).once
        end
      end

      it 'logs an error if the upsert process fails' do
        db_error = StandardError.new('DB connection failed')
        allow(service).to receive(:query).and_return([])
        allow(service).to receive(:insert).and_raise(db_error)

        result = subject.process

        expect(result[:error]).not_to be_nil
        expect(result[:error][:message]).to eq('DB connection failed')

        expect(BAS_LOGGER).to have_received(:error)
                          .with(hash_including(
                                  message: 'Ingestion failed during upsert: DB connection failed'
                                )).once
      end

      it 'logs a warning for an unknown entity type' do
        allow(mock_response.data).to receive(:[]).with('type').and_return('unknown_entity')

        result = subject.process
        expect(result).to eq({ success: { processed: 0 } })

        expect(BAS_LOGGER).to have_received(:warn)
                          .with(hash_including(
                                  message: "Ingestion skipped: type 'unknown_entity' not serviceable."
                                )).once
      end

      context 'when the response is unprocessable' do
        before do
          allow(subject).to receive(:unprocessable_response).and_return(true)
        end

        it 'skips processing and logs info' do
          result = subject.process

          expect(result).to eq({ success: { processed: 0 } })
          expect(service).not_to have_received(:query)

          expect(BAS_LOGGER).to have_received(:info).with(hash_including(
                                                            message: 'Ingestion skipped: unprocessable response.'
                                                          )).once
        end
      end
    end
  end
end
