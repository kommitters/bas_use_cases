# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'ostruct'

require_relative '../../../../src/implementations/fetch_hired_persons_from_notion'
require_relative '../../../../src/utils/warehouse/notion/hired_person_formatter'
require_relative '../../../../src/services/postgres/person'

RSpec.describe Implementation::FetchHiredPersonsFromNotionDatabase do
  subject(:bot) { described_class.new(options, shared_storage_reader, shared_storage_writer) }

  let(:options) do
    {
      database_id: 'fake_hired_persons_db_id',
      secret: 'fake_notion_secret',
      entity: 'person',
      db: nil
    }
  end

  let(:shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:person_formatter) { double('Utils::Warehouse::Notion::Formatter::HiredPersonFormatter') }
  let(:person_service) { instance_double(Services::Postgres::Person) }

  before do
    allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
    allow(Services::Postgres::Person).to receive(:new).and_return(person_service)
  end

  describe '#process' do
    context 'when the Notion API call fails' do
      let(:error_response) { double('HTTParty::Response', code: 401, parsed_response: { 'message' => 'Unauthorized' }) }

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(error_response)
      end

      it 'returns an error hash' do
        result = bot.process
        expect(result).to have_key(:error)
        expect(result.dig(:error, :status_code)).to eq(401)
        expect(result.dig(:error, :message)).to eq({ 'message' => 'Unauthorized' })
      end
    end

    context 'when the Notion API call is successful' do
      let(:notion_record_one) { { 'id' => 'notion-id-1' } }
      let(:notion_record_two) { { 'id' => 'notion-id-2' } }
      let(:formatted_person_one) { { first_name: 'John', email_address: 'john.doe@example.com' } }
      let(:formatted_person_two) { { first_name: 'Jane', email_address: 'jane.doe@example.com' } }
      let(:warehouse_person_one) { { external_person_id: 'EXISTING_ID_123', email_address: 'john.doe@example.com' } }

      let(:formatter_for_record_one) { double('Formatter for Record One') }
      let(:formatter_for_record_two) { double('Formatter for Record Two') }

      let(:api_response) do
        double('HTTParty::Response', code: 200,
                                     parsed_response: { 'results' => [notion_record_one, notion_record_two],
                                                        'has_more' => false })
      end

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(api_response)

        allow(Utils::Warehouse::Notion::Formatter::HiredPersonFormatter).to receive(:new).with(notion_record_one)
                                                                        .and_return(formatter_for_record_one)
        allow(Utils::Warehouse::Notion::Formatter::HiredPersonFormatter).to receive(:new).with(notion_record_two)
                                                                        .and_return(formatter_for_record_two)

        allow(formatter_for_record_one).to receive(:format).and_return(formatted_person_one)
        allow(formatter_for_record_two).to receive(:format).and_return(formatted_person_two)

        allow(person_service).to receive(:query).with({ email_address: 'john.doe@example.com' })
                                                .and_return([warehouse_person_one])

        allow(person_service).to receive(:query).with({ email_address: 'jane.doe@example.com' }).and_return([])
      end

      it 'assigns an existing ID to people found in the warehouse' do
        result = bot.process
        person_one_result = result.dig(:success, :content).find { |p| p[:email_address] == 'john.doe@example.com' }
        expect(person_one_result[:external_person_id]).to eq('EXISTING_ID_123')
      end

      it 'assigns a new ID (NEW_notion_id) to people not found' do
        result = bot.process
        person_two_result = result.dig(:success, :content).find { |p| p[:email_address] == 'jane.doe@example.com' }
        expect(person_two_result[:external_person_id]).to eq('NEW_notion-id-2')
      end

      it 'filters out records that have no email after formatting' do
        allow(formatter_for_record_one).to receive(:format).and_return({ first_name: 'No Email Person',
                                                                         email_address: ' ' })

        result = bot.process
        content = result.dig(:success, :content)

        expect(content.size).to eq(1)
        expect(content.first[:first_name]).to eq('Jane')
      end

      context 'with pagination' do
        let(:api_response_page_one) do
          double('HTTParty::Response', code: 200,
                                       parsed_response: { 'results' => [notion_record_one],
                                                          'has_more' => true, 'next_cursor' => 'cursor_123' })
        end
        let(:api_response_page_two) do
          double('HTTParty::Response', code: 200,
                                       parsed_response: { 'results' => [notion_record_two], 'has_more' => false })
        end

        before do
          allow(Utils::Notion::Request).to receive(:execute).and_return(api_response_page_one, api_response_page_two)
        end

        it 'makes multiple API calls and concatenates the results' do
          expect(Utils::Notion::Request).to receive(:execute).twice
          result = bot.process
          content = result.dig(:success, :content)
          expect(content.size).to eq(2)
          expect(content.map { |p| p[:first_name] }).to contain_exactly('John', 'Jane')
        end
      end
    end
  end

  describe '#write' do
    before do
      allow(bot).to receive(:process_response).and_return(process_response)
    end

    context 'when there is content to write' do
      let(:content) { Array.new(250) { { normalized_data: true } } }
      let(:process_response) { { success: { type: 'person', content: content } } }

      it 'writes one record to storage for each page of 100 items' do
        expect(shared_storage_writer).to receive(:write).exactly(3).times
        bot.write
      end

      it 'builds the record for the first page correctly' do
        expected_first_record = {
          success: {
            type: 'person',
            content: content.first(100),
            page_index: 1,
            total_pages: 3,
            total_records: 250
          }
        }
        expect(shared_storage_writer).to receive(:write).with(expected_first_record).ordered
        expect(shared_storage_writer).to receive(:write).twice.ordered
        bot.write
      end
    end

    context 'when there is no content to write' do
      let(:process_response) { { success: { type: 'person', content: [] } } }

      it 'does not call the write method on the storage writer' do
        expect(shared_storage_writer).not_to receive(:write)
        bot.write
      end
    end
  end
end
