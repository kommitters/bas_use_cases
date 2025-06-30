# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require 'ostruct'
require_relative '../../../../src/implementations/fetch_records_from_notion_database'
require_relative '../../../../src/utils/warehouse/notion/milestone_formatter'

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
  let(:project_formatter) do
    instance_double(Utils::Warehouse::Notion::Formatter::ProjectFormatter, format: { project_normalized: true })
  end

  before do
    allow(Utils::Warehouse::Notion::Formatter::ProjectFormatter).to receive(:new).and_return(project_formatter)
    allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
  end

  describe '#process' do
    context 'when Notion API call for main entities fails' do
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

    context 'when Notion API call for main entities is successful' do
      let(:notion_api_response) do
        double('HTTParty::Response',
               code: 200,
               parsed_response: { 'results' => [{ id: 'proj_1' }], 'has_more' => false })
      end
      let(:formatted_projects) { [{ project_normalized: true }] }

      before do
        allow(Utils::Notion::Request).to receive(:execute).and_return(notion_api_response)
      end

      context 'and entity is "project"' do
        it 'fetches nested milestones and includes them in the response' do
          mock_milestones = [{ milestone_normalized: true }]
          # Mock the formatter's class method to control its output
          expect(Utils::Warehouse::Notion::Formatter::MilestoneFormatter)
            .to receive(:fetch_for_projects)
            .with(formatted_projects, secret: 'fake_secret')
            .and_return(mock_milestones)

          result = bot.process

          expect(result).to have_key(:success)
          expect(result.dig(:success, :type)).to eq('project')
          expect(result.dig(:success, :content)).to eq(formatted_projects)
          # Verify the nested structure
          expect(result.dig(:success, :nested, :type)).to eq('milestone')
          expect(result.dig(:success, :nested, :content)).to eq(mock_milestones)
        end

        it 'does not include the :nested key if no milestones are found' do
          # Mock the formatter to return an empty array
          expect(Utils::Warehouse::Notion::Formatter::MilestoneFormatter)
            .to receive(:fetch_for_projects)
            .and_return([])

          result = bot.process

          expect(result[:success]).not_to have_key(:nested)
        end
      end

      context 'and entity is not "project"' do
        let(:options) { super().merge(entity: 'activity') }
        # --- CORRECCIÓN ---
        # Se añade un mock para el ActivityFormatter para evitar el error.
        let(:activity_formatter) do
          instance_double(Utils::Warehouse::Notion::Formatter::ActivityFormatter, format: { activity_normalized: true })
        end

        before do
          allow(Utils::Warehouse::Notion::Formatter::ActivityFormatter).to receive(:new).and_return(activity_formatter)
        end

        it 'does not attempt to fetch milestones' do
          # Expect that the milestone fetcher is NEVER called
          expect(Utils::Warehouse::Notion::Formatter::MilestoneFormatter).not_to receive(:fetch_for_projects)
          bot.process
        end
      end
    end
  end

  describe '#write' do
    it 'writes one record per 100 or fewer items in content' do
      content = Array.new(205) { { normalized: true } }
      process_response = { success: { type: 'project', content: content } }
      allow(bot).to receive(:process_response).and_return(process_response)

      expect(shared_storage_writer).to receive(:write).exactly(3).times
      bot.write
    end

    it 'writes for both main and nested content' do
      main_content = Array.new(150) { { project: true } } # 2 pages
      nested_content = Array.new(50) { { milestone: true } } # 1 page
      process_response = {
        success: {
          type: 'project', content: main_content,
          nested: { type: 'milestone', content: nested_content }
        }
      }
      allow(bot).to receive(:process_response).and_return(process_response)

      # Expect 2 writes for projects and 1 for milestones
      expect(shared_storage_writer).to receive(:write).with(hash_including(success: hash_including(type: 'project'))).twice # rubocop:disable Layout/LineLength
      expect(shared_storage_writer).to receive(:write).with(hash_including(success: hash_including(type: 'milestone'))).once # rubocop:disable Layout/LineLength
      bot.write
    end

    it 'writes nothing if content is empty' do
      process_response = { success: { type: 'project', content: [] } }
      allow(bot).to receive(:process_response).and_return(process_response)

      expect(shared_storage_writer).not_to receive(:write)
      bot.write
    end
  end
end
