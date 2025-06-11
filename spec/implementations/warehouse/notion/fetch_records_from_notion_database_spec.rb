# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'ostruct'
require_relative '../../../../src/implementations/fetch_records_from_notion_database'

RSpec.describe Implementation::FetchRecordsFromNotionDatabase do
  let(:options) do
    {
      database_id: 'fake_db_id',
      secret: 'fake_secret',
      entity: 'project'
    }
  end

  let(:shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:subject) { described_class.new(options, shared_storage_reader, shared_storage_writer) }
  let(:formatter) { double('Formatter::ProjectFormatter', format: { normalized: true }) }

  before do
    allow(Utils::Warehouse::Notion::Formatter::ProjectFormatter).to receive(:new).and_return(formatter)
    allow(shared_storage_reader).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
    allow(subject).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
  end

  describe '#process' do
    context 'when Notion response is successful and has no more pages' do
      let(:notion_response) do
        double('HTTParty::Response',
               code: 200,
               parsed_response: {
                 'results' => [{ id: 1 }, { id: 2 }],
                 'has_more' => false
               })
      end

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(notion_response)
      end

      it 'returns success response with normalized entities in content' do
        result = subject.process
        expect(result).to have_key(:success)
        expect(result[:success][:type]).to eq('project')
        all_content = result[:success][:pages].flat_map { |p| p[:content] }
        expect(all_content).to all(eq({ normalized: true }))
      end
    end

    context 'when Notion response is successful and has more pages' do
      let(:paged_response1) do
        double('HTTParty::Response',
               code: 200,
               parsed_response: {
                 'results' => [{ id: 1 }],
                 'has_more' => true,
                 'next_cursor' => 'abc123'
               })
      end

      let(:paged_response2) do
        double('HTTParty::Response',
               code: 200,
               parsed_response: {
                 'results' => [{ id: 2 }],
                 'has_more' => false
               })
      end

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(paged_response1, paged_response2)
      end

      it 'fetches all pages and returns all normalized entities' do
        result = subject.process
        all_content = result[:success][:pages].flat_map { |p| p[:content] }
        expect(all_content.size).to eq(2)
        expect(all_content).to all(eq({ normalized: true }))
      end
    end

    context 'when Notion response is an error' do
      let(:error_response) do
        double('HTTParty::Response',
               code: 400,
               parsed_response: { 'message' => 'Bad request' })
      end

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(error_response)
      end

      it 'returns error_response with status_code' do
        result = subject.process
        expect(result).to have_key(:error)
        expect(result[:error][:status_code]).to eq(400)
      end
    end
  end
end
