# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'ostruct'

ENV['OPERATON_API_BASE_URI'] ||= 'https://example.test'
ENV['OPERATON_USER_ID'] ||= 'test-user'
ENV['OPERATON_PASSWORD_SECRET'] ||= 'test-secret'

require_relative '../../../src/implementations/fetch_records_from_operaton'
require_relative '../../../src/utils/warehouse/operaton/request'
require_relative '../../../src/utils/warehouse/operaton/activity_formatter'

RSpec.describe Implementation::FetchRecordsFromOperaton do
  subject(:bot) { described_class.new(options, shared_storage) }

  let(:options) do
    {
      entity: 'operaton_activity',
      endpoint: 'history/activity-instance',
      method: :post,
      body: { startedAfter: '2025-10-01T00:00:00.000+0000' }
    }
  end

  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    allow(shared_storage).to receive(:write)
  end

  describe '#write' do
    let(:api_response) do
      double('HTTParty::Response', success?: true, parsed_response: [operaton_record_one, operaton_record_two])
    end
    let(:operaton_record_one) { { 'id' => 'activity-1' } }
    let(:operaton_record_two) { { 'id' => 'activity-2' } }
    let(:formatted_record_one) { { external_id: 'activity-1' } }
    let(:formatted_record_two) { { external_id: 'activity-2' } }
    let(:formatter_one) { instance_double(Utils::Warehouse::Operaton::Formatter::ActivityFormatter) }
    let(:formatter_two) { instance_double(Utils::Warehouse::Operaton::Formatter::ActivityFormatter) }

    before do
      allow(Utils::Operaton::Request).to receive(:execute).and_return(api_response)
      allow(Utils::Warehouse::Operaton::Formatter::ActivityFormatter)
        .to receive(:new).with(operaton_record_one).and_return(formatter_one)
      allow(Utils::Warehouse::Operaton::Formatter::ActivityFormatter)
        .to receive(:new).with(operaton_record_two).and_return(formatter_two)
      allow(formatter_one).to receive(:format).and_return(formatted_record_one)
      allow(formatter_two).to receive(:format).and_return(formatted_record_two)
    end

    it 'calls the API and writes formatted records to storage' do
      expect(Utils::Operaton::Request).to receive(:execute).with(
        endpoint: 'history/activity-instance',
        query_params: { first_result: 0, max_results: 100 },
        method: :post,
        body: { startedAfter: '2025-10-01T00:00:00.000+0000' }
      )

      expected_record = {
        success: {
          type: 'operaton_activity',
          content: [formatted_record_one, formatted_record_two],
          page_index: 0,
          total_pages: -1,
          total_records: -1
        }
      }
      expect(shared_storage).to receive(:write).with(expected_record)

      bot.write
    end

    context 'with pagination' do
      let(:api_response_page_one) { double('HTTParty::Response', success?: true, parsed_response: Array.new(100) { { 'id' => 'activity-page-1' } }) }
      let(:api_response_page_two) { double('HTTParty::Response', success?: true, parsed_response: [{ 'id' => 'activity-page-2' }]) }

      before do
        allow(Utils::Operaton::Request).to receive(:execute).and_return(api_response_page_one, api_response_page_two)
        allow(Utils::Warehouse::Operaton::Formatter::ActivityFormatter).to receive(:new).and_return(formatter_one)
        allow(formatter_one).to receive(:format).and_return(formatted_record_one)
      end

      it 'makes multiple API calls and writes to storage for each page' do
        expect(Utils::Operaton::Request)
          .to receive(:execute).with(hash_including(query_params: { first_result: 0, max_results: 100 })).ordered
        expect(Utils::Operaton::Request)
          .to receive(:execute).with(hash_including(query_params: { first_result: 100, max_results: 100 })).ordered

        expect(shared_storage).to receive(:write).twice

        bot.write
      end
    end

    context 'when API call fails' do
      let(:error_response) { double('HTTParty::Response', success?: false, code: 500, parsed_response: { 'message' => 'Server Error' }) }

      before do
        allow(Utils::Operaton::Request).to receive(:execute).and_return(error_response)
      end

      it 'raises an error' do
        expect { bot.write }.to raise_error('Operaton pagination error: 500 - {"message"=>"Server Error"}')
      end
    end
  end
end
