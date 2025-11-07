# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'ostruct'
ENV['APEX_API_BASE_URI'] ||= 'https://example.test'
ENV['APEX_CLIENT_ID'] ||= 'test-client'
ENV['APEX_CLIENT_SECRET'] ||= 'test-secret'
require_relative '../../../../src/implementations/fetch_records_from_apex_database'
require_relative '../../../../src/utils/warehouse/apex/request'
require_relative '../../../../src/utils/warehouse/apex/work_item_formatter'

RSpec.describe Implementation::FetchRecordsFromApexDatabase do
  subject(:bot) { described_class.new(options, shared_storage) }

  let(:options) do
    {
      entity: 'work_item',
      endpoint: 'work_items' # Assuming the endpoint is just the entity name
    }
  end

  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  # Mock the response from the warehouse, which provides the last sync date
  before do
    allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
    allow(shared_storage).to receive(:write) # Stub the write method for #process tests
  end

  describe '#process' do
    context 'when the APEX API call fails' do
      let(:error_response) do
        double('HTTParty::Response',
               success?: false,
               code: 500,
               message: 'Internal Server Error',
               parsed_response: { 'error' => 'Detail' })
      end

      before do
        allow(Utils::Apex::Request).to receive(:execute).and_return(error_response)
      end

      it 'raises an ArgumentError' do
        expected_error_payload = { message: 'Internal Server Error', status_code: 500 }.to_s

        expect { bot.process }.to raise_error(ArgumentError, expected_error_payload)
      end
    end

    context 'when the APEX API call is successful' do
      let(:apex_record_one) { { 'id' => 'apex-id-1', 'title' => 'First Task' } }
      let(:apex_record_two) { { 'id' => 'apex-id-2', 'title' => 'Second Task' } }
      let(:formatted_record_one) { { external_id: 'apex-id-1', name: 'First Task' } }
      let(:formatted_record_two) { { external_id: 'apex-id-2', name: 'Second Task' } }
      let(:formatter_one) { instance_double(Utils::Warehouse::Apex::Formatter::WorkItemFormatter) }
      let(:formatter_two) { instance_double(Utils::Warehouse::Apex::Formatter::WorkItemFormatter) }

      let(:api_response) do
        double('HTTParty::Response', success?: true, code: 200,
                                     parsed_response: {
                                       'items' => [apex_record_one, apex_record_two],
                                       'hasMore' => false
                                     })
      end

      before do
        # Stub the main API request
        allow(Utils::Apex::Request).to receive(:execute).and_return(api_response)

        # Stub the formatter logic
        allow(Utils::Warehouse::Apex::Formatter::WorkItemFormatter).to receive(:new).with(apex_record_one)
                                                                   .and_return(formatter_one)
        allow(Utils::Warehouse::Apex::Formatter::WorkItemFormatter).to receive(:new).with(apex_record_two)
                                                                   .and_return(formatter_two)
        allow(formatter_one).to receive(:format).and_return(formatted_record_one)
        allow(formatter_two).to receive(:format).and_return(formatted_record_two)
      end

      it 'returns a success hash with the formatted content' do
        result = bot.process
        expect(result).to have_key(:success)
        expect(result.dig(:success, :type)).to eq('work_item')
        expect(result.dig(:success, :content)).to contain_exactly(formatted_record_one, formatted_record_two)
      end

      context 'when no last update date is present (first run)' do
        it 'calls the API without a date parameter' do
          expect(Utils::Apex::Request).to receive(:execute).with(
            endpoint: 'work_items',
            params: {} # Expects an empty params hash
          )
          bot.process
        end
      end

      context 'when a last update date is present' do
        let(:last_sync_time) { Time.now - 3600 }

        before do
          allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: last_sync_time.to_s))
        end

        it 'calls the API with the correct last_update_date parameter' do
          expected_date = last_sync_time.utc.iso8601
          expect(Utils::Apex::Request).to receive(:execute).with(
            endpoint: 'work_items',
            params: { last_update_date: expected_date }
          )
          bot.process
        end
      end

      context 'with pagination' do
        let(:api_response_page_one) do
          double('HTTParty::Response', success?: true, code: 200,
                                       parsed_response: {
                                         'items' => [apex_record_one],
                                         'hasMore' => true,
                                         'offset' => 0,
                                         'limit' => 1
                                       })
        end
        let(:api_response_page_two) do
          double('HTTParty::Response', success?: true, code: 200,
                                       parsed_response: {
                                         'items' => [apex_record_two],
                                         'hasMore' => false
                                       })
        end

        before do
          allow(Utils::Apex::Request).to receive(:execute).and_return(api_response_page_one, api_response_page_two)
        end

        it 'makes multiple API calls and concatenates the results' do
          # Expect the first call with no offset
          expect(Utils::Apex::Request).to receive(:execute).with(hash_including(params: {})).ordered
          # Expect the second call with the calculated offset
          expect(Utils::Apex::Request).to receive(:execute).with(hash_including(params: { offset: 1 })).ordered

          result = bot.process
          content = result.dig(:success, :content)
          expect(content.size).to eq(2)
          expect(content.map { |r| r[:name] }).to contain_exactly('First Task', 'Second Task')
        end
      end
    end
  end

  describe '#write' do
    before do
      # Stub the process_response so we can test #write in isolation
      allow(bot).to receive(:process_response).and_return(process_response)
    end

    context 'when there is content to write' do
      let(:content) { Array.new(150) { { normalized_data: true } } }
      let(:process_response) { { success: { type: 'work_item', content: content } } }

      it 'writes one record to storage for each page of 100 items' do
        # 150 items should result in 2 pages (100, 50)
        expect(shared_storage).to receive(:write).exactly(2).times
        bot.write
      end

      it 'builds the record for the last page correctly' do
        expected_last_record = {
          success: {
            type: 'work_item',
            content: content.last(50), # The last page has 50 items
            page_index: 2,
            total_pages: 2,
            total_records: 150
          }
        }
        # Expect the first call, then the second call with the specific payload
        expect(shared_storage).to receive(:write).ordered
        expect(shared_storage).to receive(:write).with(expected_last_record).ordered
        bot.write
      end
    end

    context 'when there is no content to write' do
      let(:process_response) { { success: { type: 'work_item', content: [] } } }

      it 'does not call the write method on the storage writer' do
        expect(shared_storage).not_to receive(:write)
        bot.write
      end
    end
  end
end
