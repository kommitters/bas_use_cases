# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

# Set required environment variables for config loading
ENV['WAREHOUSE_POSTGRES_DB'] = 'test_warehouse_db'

require 'rspec'
require 'rack/test'
require 'json'
require 'sinatra/base'
require 'bas/shared_storage/postgres'
require 'bas/shared_storage/default'

module Config
  CONNECTION = { mocked: true }.freeze
end

require_relative '../../../src/use_cases_execution/warehouse/google_workspace/listen_to_google_calendar_updates'
require_relative '../../../src/implementations/format_workspace_calendar_events'

RSpec.describe Routes::CalendarEvents do
  include Rack::Test::Methods

  def app
    described_class.new({})
  end

  let(:mocked_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:mocked_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:mocked_formatter) { instance_double(Implementation::FormatWorkspaceCalendarEvents) }

  let(:alpha_event_activities) do
    event_id = 'evt_project_alpha'
    [
      {
        'id' => { 'time' => Time.now.to_s },
        'events' => [{
          'name' => 'create_event',
          'parameters' => [
            { 'name' => 'event_id', 'value' => event_id },
            { 'name' => 'event_title', 'value' => 'Initial Review' }
          ]
        }]
      },
      {
        'id' => { 'time' => Time.now.to_s },
        'events' => [{
          'name' => 'change_event_title',
          'parameters' => [
            { 'name' => 'event_id', 'value' => event_id },
            { 'name' => 'event_title', 'value' => 'Final Review Project Alpha' }
          ]
        }]
      }
    ]
  end

  let(:simple_event_activity) do
    [{
      'id' => { 'time' => Time.now.to_s },
      'events' => [{
        'name' => 'create_event',
        'parameters' => [
          { 'name' => 'event_id', 'value' => 'evt_simple_meeting' },
          { 'name' => 'event_title', 'value' => 'Quick Sync' }
        ]
      }]
    }]
  end

  let(:valid_payload) do
    {
      'calendar_events' => alpha_event_activities + simple_event_activity
    }
  end

  def post_calendar_events(payload)
    post '/calendar_events', payload.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  before do
    allow(Bas::SharedStorage::Default).to receive(:new).and_return(mocked_storage_reader)
    allow(Bas::SharedStorage::Postgres).to receive(:new).and_return(mocked_storage_writer)
    allow(Implementation::FormatWorkspaceCalendarEvents).to receive(:new).and_return(mocked_formatter)
    allow(mocked_formatter).to receive(:execute)
    allow_any_instance_of(Routes::CalendarEvents).to receive(:logger).and_return(double('logger').as_null_object)
  end

  context 'POST /calendar_events' do
    it 'returns 400 for empty request body' do
      post '/calendar_events', '', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Empty request body')
    end

    it 'returns 400 for invalid JSON' do
      post '/calendar_events', '{not valid json}', { 'CONTENT_TYPE' => 'application/json' }
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Invalid JSON format')
    end

    it 'returns 400 for missing calendar_events key' do
      post_calendar_events({ 'wrong_key' => [] })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "calendar_events" array')
    end

    it 'returns 400 if calendar_events is not an array' do
      post_calendar_events({ 'calendar_events' => 'not an array' })
      expect(last_response.status).to eq(400)
      expect(JSON.parse(last_response.body)).to include('error' => 'Missing or invalid "calendar_events" array')
    end

    it 'returns 200 and success message when valid calendar_events are sent' do
      post_calendar_events(valid_payload)
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)).to include('message' => 'Calendar events stored successfully')
    end

    it 'calls the formatter with the correct options' do
      expect(Implementation::FormatWorkspaceCalendarEvents).to receive(:new)
        .with({ calendar_events: valid_payload['calendar_events'] }, mocked_storage_reader, mocked_storage_writer)
        .and_return(mocked_formatter)

      expect(mocked_formatter).to receive(:execute)
      post_calendar_events(valid_payload)
    end

    it 'returns 500 if the implementation fails' do
      allow(mocked_formatter).to receive(:execute).and_raise(StandardError.new('boom'))
      post_calendar_events(valid_payload)
      expect(last_response.status).to eq(500)
      expect(JSON.parse(last_response.body)).to include('error' => 'Internal Server Error:')
    end
  end
end
