# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/warehouse_ingester'

RSpec.describe Implementation::WarehouseIngester do
  let(:options) { { db: :fake_connection } }
  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:subject) { described_class.new(options, shared_storage) }

  let(:service) { instance_double(Services::Postgres::Project) }
  let(:records) { [{ 'external_project_id' => 'proj-1' }] }
  let(:mock_response) do
    double('SharedStorageResponse', data: { 'type' => 'project', 'content' => records })
  end

  before do
    allow(subject).to receive(:read_response).and_return(mock_response)
    allow(Services::Postgres::Project).to receive(:new).and_return(service)

    allow(service).to receive(:query)
    allow(service).to receive(:insert)
    allow(service).to receive(:update)
  end

  describe '#process' do
    context 'when an entity is new' do
      it 'queries for the entity and inserts it' do
        allow(service).to receive(:query).with({ external_project_id: 'proj-1' }).and_return([])

        subject.process

        expect(service).to have_received(:insert).with(hash_including('external_project_id' => 'proj-1')).once
        expect(service).not_to have_received(:update)
      end
    end

    context 'when an entity already exists' do
      it 'queries for the entity and updates it' do
        allow(service).to receive(:query).with({ external_project_id: 'proj-1' }).and_return([{ id: 10 }])

        subject.process

        expect(service).to have_received(:update).with(10, hash_including('external_project_id' => 'proj-1')).once
        expect(service).not_to have_received(:insert)
      end
    end

    context 'when a record is missing its external ID' do
      let(:records) { [{ 'name' => 'Invalid Record' }] }

      it 'does not query, insert, or update' do
        subject.process

        expect(service).not_to have_received(:query)
        expect(service).not_to have_received(:insert)
        expect(service).not_to have_received(:update)
      end
    end

    context 'with edge cases' do
      context 'when the content array is empty' do
        let(:records) { [] }

        it 'returns zero processed and does not call any service methods' do
          result = subject.process

          expect(result).to eq({ success: { processed: 0 } })
          expect(service).not_to have_received(:query)
          expect(service).not_to have_received(:insert)
          expect(service).not_to have_received(:update)
        end
      end

      it 'returns 500 if the upsert process fails' do
        allow(service).to receive(:query).and_return([])
        allow(service).to receive(:insert).and_raise(StandardError.new('DB connection failed'))

        result = subject.process

        expect(result[:error]).not_to be_nil
        expect(result[:error][:message]).to eq('DB connection failed')
      end

      it 'does nothing for an unknown entity type' do
        allow(mock_response.data).to receive(:[]).with('type').and_return('unknown_entity')

        result = subject.process
        expect(result).to eq({ success: { processed: 0 } })
      end
    end
  end
end
