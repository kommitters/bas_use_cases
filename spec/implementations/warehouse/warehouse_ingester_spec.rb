# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require_relative '../../../src/implementations/warehouse_ingester'

RSpec.describe Implementation::WarehouseIngester do
  let(:options) { { db: :fake_connection } }
  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:subject) { described_class.new(options, shared_storage) }

  before do
    allow(subject).to receive(:read_response).and_return(mock_response)
  end

  describe '#process' do
    context 'for a service WITHOUT history flag (e.g., project)' do
      let(:project_service) { instance_double(Services::Postgres::Project) }
      let(:project_records) { [{ 'external_project_id' => '123' }] }
      let(:mock_response) do
        double('SharedStorageResponse', data: { 'type' => 'project', 'content' => project_records })
      end

      before do
        allow(Services::Postgres::Project).to receive(:new).and_return(project_service)
        allow(project_service).to receive(:insert)
        allow(project_service).to receive(:update)
      end

      it 'always inserts records, regardless of whether they exist' do
        result = subject.process

        expect(result).to eq({ success: { processed: 1 } })
        expect(project_service).to have_received(:insert).with(hash_including('external_project_id' => '123'))
        expect(project_service).not_to have_received(:update)
      end

      context 'when the content is empty' do
        let(:project_records) { [] }

        it 'does nothing and returns zero processed' do
          result = subject.process

          expect(result).to eq({ success: { processed: 0 } })
          expect(project_service).not_to have_received(:insert)
          expect(project_service).not_to have_received(:update)
        end
      end
    end

    context 'for a service WITH history flag (e.g., key_result)' do
      let(:key_result_service) { instance_double(Services::Postgres::KeyResult) }
      let(:key_result_records) { [{ 'external_key_result_id' => 'kr-1' }] }
      let(:mock_response) do
        double('SharedStorageResponse', data: { 'type' => 'key_result', 'content' => key_result_records })
      end

      before do
        allow(Services::Postgres::KeyResult).to receive(:new).and_return(key_result_service)
        allow(key_result_service).to receive(:insert)
        allow(key_result_service).to receive(:update)
      end

      context 'when records are new' do
        it 'inserts the new records' do
          allow(key_result_service).to receive(:query).and_return([])

          subject.process

          expect(key_result_service).to have_received(:insert).once
          expect(key_result_service).not_to have_received(:update)
        end
      end

      context 'when records already exist' do
        it 'updates the existing records' do
          allow(key_result_service).to receive(:query).with({ external_key_result_id: 'kr-1' }).and_return([{ id: 10 }])

          subject.process

          expect(key_result_service).to have_received(:update).with(10, anything)
          expect(key_result_service).not_to have_received(:insert)
        end
      end

      context 'when receiving a mix of new and existing records' do
        let(:key_result_records) do
          [
            { 'external_key_result_id' => 'kr-existing' },
            { 'external_key_result_id' => 'kr-new' }
          ]
        end

        it 'updates the existing one and inserts the new one' do
          allow(key_result_service).to receive(:query).with({ external_key_result_id: 'kr-existing' })
                                                      .and_return([{ id: 20 }])
          allow(key_result_service).to receive(:query).with({ external_key_result_id: 'kr-new' }).and_return([])

          result = subject.process

          expect(result).to eq({ success: { processed: 2 } })
          expect(key_result_service).to have_received(:update)
                                    .with(20, hash_including('external_key_result_id' => 'kr-existing'))
            .once
          expect(key_result_service).to have_received(:insert)
                                    .with(hash_including('external_key_result_id' => 'kr-new'))
            .once
        end
      end

      context 'when a record is missing its external ID' do
        let(:key_result_records) do
          [
            { 'external_key_result_id' => 'kr-valid' },
            { 'some_other_key' => 'kr-invalid' }
          ]
        end

        it 'processes the valid record and skips the invalid one' do
          allow(key_result_service).to receive(:query).with({ external_key_result_id: 'kr-valid' })
                                                      .and_return([{ id: 30 }])

          result = subject.process

          expect(result).to eq({ success: { processed: 2 } })
          expect(key_result_service).to have_received(:update).with(30, anything).once
          expect(key_result_service).not_to have_received(:insert)
        end
      end
    end

    context 'with edge cases and error handling' do
      let(:project_service) { instance_double(Services::Postgres::Project) }
      let(:mock_response) do
        double('SharedStorageResponse',
               data: { 'type' => 'project', 'content' => [{ 'external_project_id' => '123' }] })
      end

      before do
        allow(Services::Postgres::Project).to receive(:new).and_return(project_service)
      end

      context 'when a service call raises an error' do
        it 'catches the exception and returns an error hash' do
          allow(project_service).to receive(:insert).and_raise(StandardError, 'Database connection failed')

          result = subject.process

          expect(result[:success]).to be_nil
          expect(result[:error]).not_to be_nil
          expect(result[:error][:message]).to eq('Database connection failed')
          expect(result[:error][:type]).to eq('project')
        end
      end

      context 'when the type is unknown' do
        let(:mock_response) do
          double('SharedStorageResponse', data: { 'type' => 'unknown_entity', 'content' => [] })
        end

        it 'returns zero processed and does nothing' do
          expect(subject.process).to eq({ success: { processed: 0 } })
        end
      end
    end
  end
end
