# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'ostruct'
require_relative '../../../../src/implementations/fetch_records_from_notion_database'
require_relative '../../../../src/utils/warehouse/notion/milestone_formatter'
require_relative '../../../../src/utils/warehouse/notion/project_formatter'

RSpec.describe Implementation::FetchRecordsFromNotionDatabase do
  subject(:bot) { described_class.new(options, shared_storage_reader, shared_storage_writer) }

  let(:options) do
    {
      database_id: 'fake_db_id',
      secret: 'fake_secret',
      entity: 'project'
    }
  end

  let(:shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }

  before do
    # General setup to mock the read response for all tests
    allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
  end

  describe '#process' do
    context 'when Notion API call fails' do
      let(:error_response) { double('HTTParty::Response', code: 401, parsed_response: { 'message' => 'Unauthorized' }) }

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(error_response)
      end

      it 'returns an error hash' do
        result = bot.process
        expect(result).to have_key(:error)
        expect(result.dig(:error, :status_code)).to eq(401)
      end
    end

    context 'when fetching a standard entity (e.g., project)' do
      let(:options) { super().merge(entity: 'project') }
      let(:project_formatter) { instance_double(Utils::Warehouse::Notion::Formatter::ProjectFormatter) }
      let(:notion_api_response) do
        double('HTTParty::Response',
               code: 200,
               parsed_response: { 'results' => [{ 'id' => 'proj_1' }], 'has_more' => false })
      end

      before do
        allow(Utils::Warehouse::Notion::Formatter::ProjectFormatter).to receive(:new).and_return(project_formatter)
        allow(project_formatter).to receive(:format).and_return({ project_normalized: true })
        allow(Utils::Notion::Request).to receive(:execute).and_return(notion_api_response)
      end

      it 'formats the records directly' do
        result = bot.process
        expect(result.dig(:success, :content)).to eq([{ project_normalized: true }])
        expect(result[:success]).not_to have_key(:nested)
      end
    end

    context 'when fetching the special "milestone" entity' do
      let(:options) { super().merge(entity: 'milestone') }
      let(:raw_project_records) { [{ 'id' => 'proj_1', 'properties' => {} }] }
      let(:notion_api_response) do
        double('HTTParty::Response',
               code: 200,
               parsed_response: { 'results' => raw_project_records, 'has_more' => false })
      end
      let(:project_formatter) { instance_double(Utils::Warehouse::Notion::Formatter::ProjectFormatter) }

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(notion_api_response)
        # Mock the internal call to the ProjectFormatter
        allow(Utils::Warehouse::Notion::Formatter::ProjectFormatter).to receive(:new).and_return(project_formatter)
        allow(project_formatter).to receive(:format).and_return({ external_project_id: 'proj_1' })
      end

      it 'delegates fetching and formatting to the MilestoneFormatter' do
        mock_milestones = [{ milestone_normalized: true }]
        # This is the key expectation, updated to reflect the correct arguments
        expect(Utils::Warehouse::Notion::Formatter::MilestoneFormatter)
          .to receive(:fetch_for_projects)
          .with(
            raw_project_records, # It receives the RAW project records
            secret: 'fake_secret',
            filter_body: an_instance_of(Hash)
          )
          .and_return(mock_milestones)

        result = bot.process

        # The final result should contain the milestones as the main content
        expect(result).to have_key(:success)
        expect(result.dig(:success, :type)).to eq('milestone')
        expect(result.dig(:success, :content)).to eq(mock_milestones)
        expect(result[:success]).not_to have_key(:nested)
      end
    end
  end

  describe '#write' do
    let(:content) { Array.new(205) { { normalized: true } } }
    let(:process_response) { { success: { type: 'project', content: content } } }

    before do
      allow(bot).to receive(:process_response).and_return(process_response)
    end

    it 'writes one record per 100 or fewer items in content' do
      expect(shared_storage_writer).to receive(:write).exactly(3).times
      bot.write
    end

    it 'writes nothing if content is empty' do
      allow(bot).to receive(:process_response).and_return({ success: { type: 'project', content: [] } })
      expect(shared_storage_writer).not_to receive(:write)
      bot.write
    end
  end
end
