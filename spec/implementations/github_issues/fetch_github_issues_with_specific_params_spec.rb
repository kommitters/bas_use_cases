# spec/implementations/fetch_github_issues_with_specific_params_spec.rb
# frozen_string_literal: true

require 'rspec'
require 'httparty'
require 'date'
require_relative '../../../src/implementations/fetch_github_issues_with_specific_params'

RSpec.describe Implementation::FetchGithubIssues do
  let(:mocked_shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_shared_storage_reader) { instance_double(Bas::SharedStorage::Postgres) }

  let(:options) do
    {
      connection: 'fake_connection',
      db_table: 'github_issues',
      tag: 'GithubIssueRequest'
    }
  end

  subject(:bot) { described_class.new(options, mocked_shared_storage_reader, mocked_shared_storage_writer) }

  before do
    allow(mocked_shared_storage_writer).to receive(:write).and_return([{ 'status' => 'success' }])
  end

  describe '#process' do
    before do
      allow(HTTParty).to receive(:get).and_return(
        instance_double(HTTParty::Response,
          code: 200,
          parsed_response: {
            'total_count' => 5,
            'incomplete_results' => false
          }
        )
      )
    end

    it 'returns a success hash with normalized data' do
      result = bot.process

      expect(result[:success]).to include(
        month: kind_of(String),
        year: kind_of(Integer),
        closed_issues: { name: '# Closed Tickets', value: 5 },
        opened_issues: { name: '# Opened Issues', value: 5 },
        previous_open_issues: { name: 'Previous Open Issues', value: 0 }
      )
    end
  end

  describe '#fetch_count' do
    context 'when API response is successful' do
      it 'returns total_count from response' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response,
            code: 200,
            parsed_response: { 'total_count' => 10, 'incomplete_results' => false }
          )
        )

        count = bot.send(:fetch_count, 'dummy query')
        expect(count).to eq(10)
      end
    end

    context 'when response code is not 200' do
      it 'returns 0' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response, code: 500)
        )

        count = bot.send(:fetch_count, 'dummy query')
        expect(count).to eq(0)
      end
    end

    context 'when incomplete_results is true' do
      it 'returns 0' do
        allow(HTTParty).to receive(:get).and_return(
          instance_double(HTTParty::Response,
            code: 200,
            parsed_response: { 'total_count' => 99, 'incomplete_results' => true }
          )
        )

        count = bot.send(:fetch_count, 'dummy query')
        expect(count).to eq(0)
      end
    end
  end
end
