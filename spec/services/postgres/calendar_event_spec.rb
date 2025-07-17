# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/calendar_event'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::CalendarEvent do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }

  before(:each) do
    db.drop_table?(:calendar_events)
    create_calendar_events_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new calendar_event and returns its ID' do
      params = {
        external_calendar_event_id: 'evt-123',
        summary: 'Test Event',
        duration_minutes: 60,
        start_time: Time.now,
        end_time: Time.now + 3600,
        creation_timestamp: Time.now - 86_400
      }
      id = service.insert(params)
      event = service.find(id)

      expect(event[:summary]).to eq('Test Event')
      expect(event[:external_calendar_event_id]).to eq('evt-123')
      expect(event[:duration_minutes]).to eq(60)
    end
  end

  describe '#update' do
    let(:event_id) do
      service.insert(
        external_calendar_event_id: 'evt-to-update',
        summary: 'Old Summary',
        duration_minutes: 30,
        start_time: Time.now,
        end_time: Time.now + 1800,
        creation_timestamp: Time.now - 86_400
      )
    end

    it 'updates a calendar_event by ID' do
      service.update(event_id, { summary: 'Updated Summary', duration_minutes: 45 })
      updated = service.find(event_id)

      expect(updated[:summary]).to eq('Updated Summary')
      expect(updated[:duration_minutes]).to eq(45)
    end

    it 'raises an error if no ID is provided' do
      expect { service.update(nil, { summary: 'No ID' }) }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a calendar_event by ID' do
      id = service.insert(external_calendar_event_id: 'evt-to-delete', summary: 'To Delete', duration_minutes: 15,
                          start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a calendar_event by ID' do
      id = service.insert(external_calendar_event_id: 'evt-to-find', summary: 'Find Me', duration_minutes: 10,
                          start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)
      found = service.find(id)

      expect(found[:id]).to eq(id)
      expect(found[:summary]).to eq('Find Me')
    end
  end

  describe '#query' do
    before do
      service.insert(external_calendar_event_id: 'evt-query-1', summary: 'Query Me', duration_minutes: 5,
                     start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)
      service.insert(external_calendar_event_id: 'evt-query-2', summary: 'Another Event', duration_minutes: 25,
                     start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)
    end

    it 'queries calendar_events by condition' do
      results = service.query(summary: 'Query Me')
      expect(results.size).to eq(1)
      expect(results.first[:external_calendar_event_id]).to eq('evt-query-1')
    end

    it 'returns all calendar_events with empty conditions' do
      expect(service.query.size).to eq(2)
    end
  end
end
