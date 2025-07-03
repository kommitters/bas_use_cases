# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'ostruct'

# --- Require the actual dependency files ---
require_relative '../../../../src/implementations/fetch_records_from_work_logs'
require_relative '../../../../src/utils/warehouse/work_logs/request'
require_relative '../../../../src/utils/warehouse/work_logs/work_log_formatter'

RSpec.describe Implementation::FetchRecordsFromWorkLogs do
  let(:options) do
    {
      work_logs_url: 'http://fake-api.com',
      secret: 'fake-secret-123',
      entity: 'work_log'
    }
  end

  let(:shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:subject) do
    described_class.new(options, shared_storage_reader, shared_storage_writer)
  end
  let(:formatter) { double('WorkLogFormatter', format: { normalized: true }) }

  before do
    allow(Utils::Warehouse::WorkLogs::WorkLogFormatter).to receive(:new).and_return(formatter)
    allow(subject).to receive(:read_response).and_return(OpenStruct.new(inserted_at: '2025-07-01'))
    allow(Date).to receive(:today).and_return(Date.parse('2025-07-02'))
  end

  describe '#process' do
    context 'when API response is successful and has only one page' do
      let(:api_response) do
        double('HTTParty::Response',
               success?: true,
               parsed_response: {
                 'logs' => [{ id: 1 }, { id: 2 }]
               })
      end

      before do
        allow(Utils::WorkLogs::Request).to receive(:execute).and_return(api_response)
      end

      it 'returns a success response with all normalized entities' do
        result = subject.process
        expect(result).to have_key(:success)
        expect(result[:success][:type]).to eq('work_log')
        expect(result[:success][:content]).to eq([{ normalized: true }, { normalized: true }])
      end
    end

    context 'when API response is successful and has multiple pages' do
      let(:paged_response1) do
        double('HTTParty::Response',
               success?: true,
               parsed_response: { 'logs' => Array.new(100) { { id: 1 } } })
      end
      let(:paged_response2) do
        double('HTTParty::Response',
               success?: true,
               parsed_response: { 'logs' => [{ id: 2 }] })
      end

      before do
        allow(Utils::WorkLogs::Request).to receive(:execute).and_return(paged_response1, paged_response2)
      end

      it 'fetches all pages and returns all normalized entities' do
        result = subject.process
        expect(result[:success][:content].size).to eq(101)
      end
    end

    context 'when API response is an error' do
      let(:error_response) do
        double('HTTParty::Response', success?: false, code: 500, message: 'Server Error')
      end

      before do
        allow(Utils::WorkLogs::Request).to receive(:execute).and_return(error_response)
      end

      it 'raises a runtime error with a specific message' do
        expect { subject.process }.to raise_error(RuntimeError, 'Error fetching data: 500 - Server Error')
      end
    end
  end

  describe '#write' do
    it 'writes one record per 100 or fewer items in content' do
      content = Array.new(205) { { normalized: true } }
      process_response = { success: { type: 'work_log', content: content } }
      allow(subject).to receive(:process_response).and_return(process_response)

      expect(shared_storage_writer).to receive(:write).exactly(3).times

      subject.write
    end

    it 'writes nothing if content is empty' do
      process_response = { success: { type: 'work_log', content: [] } }
      allow(subject).to receive(:process_response).and_return(process_response)
      expect(shared_storage_writer).not_to receive(:write)
      subject.write
    end
  end
end
