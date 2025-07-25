# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/calendar_event_attendee'
require_relative '../../../src/services/postgres/calendar_event'
require_relative '../../../src/services/postgres/person'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::CalendarEventAttendee do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }

  let(:service) { described_class.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }
  let(:calendar_event_service) { Services::Postgres::CalendarEvent.new(config) }

  before(:each) do
    db.drop_table?(:calendar_event_attendees)
    db.drop_table?(:calendar_events)
    db.drop_table?(:persons)
    db.drop_table?(:domains)

    create_domains_table(db)
    create_persons_table(db)
    create_calendar_events_table(db)
    create_calendar_event_attendees_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  # Test data
  let!(:person_id) do
    person_service.insert(
      external_person_id: 'p-1',
      full_name: 'Test Person',
      email_address: 'test@example.com'
    )
  end

  let!(:calendar_event_id) do
    calendar_event_service.insert(
      external_calendar_event_id: 'evt-1',
      summary: 'Test Event',
      duration_minutes: 60,
      start_time: Time.now,
      end_time: Time.now + 3600,
      creation_timestamp: Time.now
    )
  end

  describe '#insert' do
    it 'creates a new attendee by resolving email to person_id' do
      params = {
        calendar_event_id: calendar_event_id,
        email_address: 'test@example.com',
        response_status: 'accepted'
      }

      attendee_id = service.insert(params)
      attendee = service.find(attendee_id)

      expect(attendee).not_to be_nil
      expect(attendee[:person_id]).to eq(person_id)
      expect(attendee[:calendar_event_id]).to eq(calendar_event_id)
      expect(attendee[:response_status]).to eq('accepted')
    end
  end

  describe '#update' do
    let!(:attendee_id) do
      service.insert(
        calendar_event_id: calendar_event_id,
        person_id: person_id,
        response_status: 'accepted'
      )
    end

    let!(:new_person_id) do
      person_service.insert(
        external_person_id: 'p-2',
        full_name: 'New Person',
        email_address: 'new@example.com'
      )
    end

    it 'updates the response_status of an attendee' do
      service.update(attendee_id, { response_status: 'declined' })
      updated_attendee = service.find(attendee_id)
      expect(updated_attendee[:response_status]).to eq('declined')
    end

    it 'updates the person associated with an attendee using email' do
      service.update(attendee_id, { email_address: 'new@example.com' })
      updated_attendee = service.find(attendee_id)
      expect(updated_attendee[:person_id]).to eq(new_person_id)
    end

    it 'raises an error if no ID is provided' do
      expect { service.update(nil, { response_status: 'tentative' }) }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes an attendee by ID' do
      attendee_id = service.insert(
        calendar_event_id: calendar_event_id,
        person_id: person_id,
        response_status: 'accepted'
      )

      expect(service.find(attendee_id)).not_to be_nil
      expect { service.delete(attendee_id) }.to change { service.query.size }.by(-1)
      expect(service.find(attendee_id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds an attendee by ID' do
      attendee_id = service.insert(
        calendar_event_id: calendar_event_id,
        person_id: person_id,
        response_status: 'needsAction'
      )

      found_attendee = service.find(attendee_id)

      expect(found_attendee[:id]).to eq(attendee_id)
      expect(found_attendee[:person_id]).to eq(person_id)
    end
  end

  describe '#query' do
    before do
      other_person_id = person_service.insert(
        external_person_id: 'p-other',
        full_name: 'Other',
        email_address: 'other@example.com'
      )
      other_event_id = calendar_event_service.insert(
        external_calendar_event_id: 'evt-other',
        summary: 'Other Event',
        duration_minutes: 60,
        start_time: Time.now,
        end_time: Time.now + 3600,
        creation_timestamp: Time.now
      )

      service.insert(calendar_event_id: calendar_event_id, person_id: person_id, response_status: 'accepted')
      service.insert(calendar_event_id: calendar_event_id, person_id: other_person_id, response_status: 'declined')
      service.insert(calendar_event_id: other_event_id, person_id: person_id, response_status: 'tentative')
    end

    it 'queries attendees by a condition' do
      results = service.query(calendar_event_id: calendar_event_id)
      expect(results.size).to eq(2)
    end

    it 'returns all attendees with empty conditions' do
      results = service.query
      expect(results.size).to eq(3)
    end
  end
end
