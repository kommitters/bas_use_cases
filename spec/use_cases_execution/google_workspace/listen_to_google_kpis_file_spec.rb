# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

require_relative '../../../src/use_cases_execution/warehouse/google_workspace/listen_to_google_kpis_file'
require_relative '../../../src/utils/warehouse/google_workspace/kpis_format'

RSpec.describe Routes::Kpis do
  include Rack::Test::Methods

  def app
    described_class.new({})
  end

  let(:mocked_storage_writer) { instance_double(Bas::SharedStorage::Postgres, write: nil) }
  let(:mocked_formatter_instance) { instance_double(Utils::Warehouse::GoogleWorkspace::KpisFormatter) }
  let(:formatted_result) { { external_kpi_id: 't.testkpi', description: 'Test KPI', name: 'kommit.ops' } }

  let(:raw_sheet_data) do
    [
      # Header Row
      ['Description', 'Name', 'Status', 'Current Value', 'Target Value', 'Percentage', 'external_kpi_id'],
      # Data Row 1 (with single domain)
      ['Operational Standardization Index', 'kommit.ops', 'Active', 0.55, 1, 0.55, 't.5941xodai6nr'],
      # Data Row 2 (with dual domain)
      ['Example Dual Domain Index', 'kommit, kommit.engineering', 'Active', 0.8, 1, 0.8, 't.dualdomain']
    ]
  end

  let(:valid_payload) do
    { 'key_performance_raw' => raw_sheet_data }
  end

  def post_kpis(payload)
    post '/kpis', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  context 'POST /kpis' do
    before do
      allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_storage_writer)

      allow(Utils::Warehouse::GoogleWorkspace::KpisFormatter).to receive(:new).and_return(mocked_formatter_instance)
      allow(mocked_formatter_instance).to receive(:format).and_return(formatted_result)

      allow_any_instance_of(described_class).to receive(:logger).and_return(double('logger').as_null_object)
    end

    it 'returns 400 for empty request body' do
      post '/kpis', '', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
    end

    it 'returns 400 for invalid JSON' do
      post '/kpis', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
    end

    it 'returns 400 for missing key_performance_raw key' do
      post_kpis({ 'wrong_key' => [] })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "key_performance_raw" array')
    end

    it 'returns 400 if key_performance_raw is not an array' do
      post_kpis({ 'key_performance_raw' => 'not an array' })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "key_performance_raw" array')
    end

    it 'returns 400 if data has only a header row' do
      post_kpis({ 'key_performance_raw' => [raw_sheet_data.first] })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body))
        .to include('error' => 'Input data must have a header and at least one data row.')
    end

    it 'returns 200 and a success message for a valid payload' do
      post_kpis(valid_payload)
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include('message' => 'KPIs stored successfully')
    end

    it 'calls the formatter for each data row' do
      data_rows = raw_sheet_data.slice(1..-1)
      expect(Utils::Warehouse::GoogleWorkspace::KpisFormatter).to receive(:new)
        .exactly(data_rows.count).times.and_return(mocked_formatter_instance)
      expect(mocked_formatter_instance).to receive(:format).exactly(data_rows.count).times

      post_kpis(valid_payload)
    end

    it 'calls the storage writer with the correctly formatted payload' do
      expected_content = [formatted_result, formatted_result] # Since there are two data rows
      expected_payload = { success: { type: 'kpi', content: expected_content } }

      expect(mocked_storage_writer).to receive(:write).with(expected_payload)
      post_kpis(valid_payload)
    end

    it 'returns 500 if the formatter fails' do
      allow(mocked_formatter_instance).to receive(:format).and_raise(StandardError.new('formatter boom'))
      post_kpis(valid_payload)
      expect(last_response.status).to eq(500)
      expect(JSON.parse(last_response.body)).to include('error' => 'Internal Server Error')
    end
  end

  describe Utils::Warehouse::GoogleWorkspace::KpisFormatter do
    it 'correctly extracts the name from a single-domain value' do
      data_row = ['Operational Standardization Index', 'kommit.ops', 'Active', 0.55, 1, 0.55, 't.5941xodai6nr']
      formatter = described_class.new(data_row)
      expect(formatter.format[:name]).to eq('kommit.ops')
    end

    it 'correctly extracts the first domain from a dual-domain value' do
      data_row = ['Example Dual Domain Index', 'kommit, kommit.engineering', 'Active', 0.8, 1, 0.8, 't.dualdomain']
      formatter = described_class.new(data_row)
      expect(formatter.format[:name]).to eq('kommit')
    end
  end
end
