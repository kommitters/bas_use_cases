# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

# Adjust the path to your actual routes and formatter files
require_relative '../../../src/use_cases_execution/warehouse/google_workspace/listen_to_google_key_results_file'
require_relative '../../../src/utils/warehouse/google_workspace/key_results_format'

RSpec.describe Routes::KeyResults do
  include Rack::Test::Methods

  def app
    described_class.new({})
  end

  # Mocks for dependencies
  let(:mocked_storage_writer) { instance_double(Bas::SharedStorage::Postgres, write: nil) }
  let(:mocked_formatter_instance) { instance_double(Utils::Warehouse::GoogleWorkspace::KeyResultsFormatter) }
  let(:formatted_result) { { external_key_result_id: 'some-uuid', okr: 'Test OKR' } }

  # Test data mimicking the raw payload from the App Script
  let(:raw_sheet_data) do
    [
      # Header Row
      ['Objective', 'Owner', 'Key Result', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov',
       'Dec', 'Target'],
      # Data Row 1
      ['OKR-1', 'Team A', 'Launch feature X', nil, nil, 10, 20, '-', nil, nil, nil, nil, nil, nil, nil, 100],
      # Data Row 2
      ['OKR-2', 'Team B', 'Improve performance', 5, 15, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 50]
    ]
  end

  let(:valid_payload) do
    { 'key_results_raw' => raw_sheet_data }
  end

  def post_key_results(payload)
    post '/key_results', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before do
    # Mock the storage writer
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_storage_writer)

    # Mock the formatter
    allow(Utils::Warehouse::GoogleWorkspace::KeyResultsFormatter).to receive(:new).and_return(mocked_formatter_instance)
    allow(mocked_formatter_instance).to receive(:format).and_return(formatted_result)

    # Suppress logger output in tests
    allow_any_instance_of(described_class).to receive(:logger).and_return(double('logger').as_null_object)
  end

  context 'POST /key_results' do
    it 'returns 400 for empty request body' do
      post '/key_results', '', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
    end

    it 'returns 400 for invalid JSON' do
      post '/key_results', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
    end

    it 'returns 400 for missing key_results_raw key' do
      post_key_results({ 'wrong_key' => [] })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "key_results_raw" array')
    end

    it 'returns 400 if key_results_raw is not an array' do
      post_key_results({ 'key_results_raw' => 'not an array' })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "key_results_raw" array')
    end

    it 'returns 400 if data has only a header row' do
      post_key_results({ 'key_results_raw' => [raw_sheet_data.first] })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body))
        .to include('error' => 'Input data must have a header and at least one data row.')
    end

    it 'returns 200 and a success message for a valid payload' do
      post_key_results(valid_payload)
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include('message' => 'Key results stored successfully')
    end

    it 'calls the formatter for each data row' do
      data_rows = raw_sheet_data.slice(1..-1)
      expect(Utils::Warehouse::GoogleWorkspace::KeyResultsFormatter).to receive(:new)
        .exactly(data_rows.count).times.and_return(mocked_formatter_instance)
      expect(mocked_formatter_instance).to receive(:format).exactly(data_rows.count).times

      post_key_results(valid_payload)
    end

    it 'calls the storage writer with the correctly formatted payload' do
      expected_content = [formatted_result, formatted_result] # Since there are two data rows
      expected_payload = { success: { type: 'key_result', content: expected_content } }

      expect(mocked_storage_writer).to receive(:write).with(expected_payload)
      post_key_results(valid_payload)
    end

    it 'returns 500 if the formatter fails' do
      allow(mocked_formatter_instance).to receive(:format).and_raise(StandardError.new('formatter boom'))
      post_key_results(valid_payload)
      expect(last_response.status).to eq(500)
      expect(JSON.parse(last_response.body)).to include('error' => 'Internal Server Error')
    end
  end
end
