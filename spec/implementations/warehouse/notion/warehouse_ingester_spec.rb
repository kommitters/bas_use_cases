# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require_relative '../../../../src/implementations/warehouse_ingester'

RSpec.describe Implementation::WarehouseIngester do
  let(:options) { { db: :fake_connection } }
  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:subject) { described_class.new(options, shared_storage) }

  let(:project_service) { instance_double(Services::Postgres::Project) }

  let(:project_records) do
    [
      { 'external_project_id' => '123' },
      { 'external_project_id' => '456' }
    ]
  end

  let(:mock_response) do
    double('SharedStorageResponse', data: {
             'type' => 'project',
             'content' => project_records
           })
  end

  before do
    allow(subject).to receive(:read_response).and_return(mock_response)
    allow(Services::Postgres::Project).to receive(:new).and_return(project_service)
  end

  describe '#process' do
    context 'when project records are new' do
      before do
        allow(project_service).to receive(:query).and_return([]) # no existen
        allow(project_service).to receive(:insert)
        allow(project_service).to receive(:update)
      end

      it 'inserts all new project records and returns processed count' do
        result = subject.process

        expect(result).to eq({ success: { processed: 2 } })

        project_records.each do |record|
          expect(project_service).to have_received(:insert).with(hash_including(record))
        end

        expect(project_service).not_to have_received(:update)
      end
    end

    context 'when project records already exist' do
      before do
        # Devuelve un resultado simulado por cada item
        allow(project_service).to receive(:query).and_return(
          [{ id: 1 }], [{ id: 2 }]
        )
        allow(project_service).to receive(:insert)
        allow(project_service).to receive(:update)
      end

      it 'updates existing project records and returns processed count' do
        result = subject.process

        expect(result).to eq({ success: { processed: 2 } })

        expect(project_service).to have_received(:update).with(1, hash_including('external_project_id' => '123'))
        expect(project_service).to have_received(:update).with(2, hash_including('external_project_id' => '456'))

        expect(project_service).not_to have_received(:insert)
      end
    end

    context 'when type is unknown' do
      let(:mock_response) do
        double('SharedStorageResponse', data: {
                 'type' => 'unknown_entity',
                 'content' => [{ 'some_id' => 'xyz' }]
               })
      end

      it 'returns processed count as zero and does nothing' do
        expect(subject.process).to eq({ success: { processed: 0 } })
      end
    end
  end
end
