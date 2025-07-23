# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/calendar_event'
require_relative '../../../src/services/postgres/calendar_event_attendee'
require_relative '../../../src/services/postgres/person'

require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::CalendarEventAttendee do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:event_service) { Services::Postgres::CalendarEvent.new(config) }
  let(:person_service) { Services::Postgres::Person.new(config) }

  before(:each) do
    # Drop tables in reverse order of creation
    db.drop_table?(:calendar_event_attendees)
    db.drop_table?(:calendar_events)
    db.drop_table?(:persons)
    db.drop_table?(:domains)

    # Create tables
    create_domains_table(db)
    create_persons_table(db)
    create_calendar_events_table(db)
    create_calendar_event_attendees_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    let!(:event_id) do
      event_service.insert(
        external_calendar_event_id: 'evt-1',
        summary: 'Test Event',
        duration_minutes: 60,
        start_time: Time.now,
        end_time: Time.now + 3600,
        creation_timestamp: Time.now
      )
    end

    it 'creates a new attendee and resolves the calendar_event_id' do
      params = {
        external_calendar_event_id: 'evt-1',
        email: 'test@example.com',
        response_status: 'accepted'
      }
      id = service.insert(params)
      attendee = service.find(id)

      expect(attendee[:calendar_event_id]).to eq(event_id)
      expect(attendee[:email]).to eq('test@example.com')
      expect(attendee[:response_status]).to eq('accepted')
    end

    context 'with person association' do
      let!(:person_id) do
        person_service.insert(
          external_person_id: 'ext-john',
          full_name: 'John Doe',
          email_address: 'john.doe@example.com'
        )
      end

      it 'assigns person_id if the attendee email exists in the people table' do
        params = {
          external_calendar_event_id: 'evt-1',
          email: 'john.doe@example.com', # Email que coincide con una persona existente
          response_status: 'accepted'
        }
        id = service.insert(params)
        attendee = service.find(id)

        expect(attendee[:person_id]).to eq(person_id)
      end

      it 'leaves person_id as nil if the attendee email does not exist' do
        params = {
          external_calendar_event_id: 'evt-1',
          email: 'unknown@example.com', # Email que no existe en la tabla people
          response_status: 'needsAction'
        }
        id = service.insert(params)
        attendee = service.find(id)

        expect(attendee[:person_id]).to be_nil
      end
    end
  end

  describe '#update' do
    let(:attendee_id) do
      event_id = event_service.insert(external_calendar_event_id: 'evt-2', summary: 'Event 2', duration_minutes: 30,
                                      start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)
      service.insert(calendar_event_id: event_id, email: 'attendee@example.com', response_status: 'tentative')
    end

    it 'updates an attendee by ID' do
      service.update(attendee_id, { response_status: 'declined' })
      updated = service.find(attendee_id)
      expect(updated[:response_status]).to eq('declined')
    end
    it 'raises an error if no ID is provided' do
      expect { service.update(nil, { response_status: 'accepted' }) }.to raise_error(ArgumentError)
    end

    context 'with person association' do
      let!(:person_id) do
        person_service.insert(
          external_person_id: 'ext-jane',
          full_name: 'Jane Doe',
          email_address: 'jane.doe@example.com'
        )
      end

      it 'assigns person_id on update when email is changed to match a person' do
        # Se actualiza el email para que coincida con una persona existente
        service.update(attendee_id, { email: 'jane.doe@example.com' })
        updated = service.find(attendee_id)

        expect(updated[:person_id]).to eq(person_id)
      end
    end
  end

  describe '#delete' do
    it 'deletes an attendee by ID' do
      event_id = event_service.insert(external_calendar_event_id: 'evt-3', summary: 'Event 3', duration_minutes: 15,
                                      start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)
      id = service.insert(calendar_event_id: event_id, email: 'delete@example.com', response_status: 'accepted')

      expect { service.delete(id) }.to change { service.query.size }.by(-1)
      expect(service.find(id)).to be_nil
    end
  end

  describe '#query' do
    before do
      event_id = event_service.insert(external_calendar_event_id: 'evt-4', summary: 'Event 4', duration_minutes: 10,
                                      start_time: Time.now, end_time: Time.now, creation_timestamp: Time.now)
      service.insert(calendar_event_id: event_id, email: 'query@example.com', response_status: 'accepted')
    end

    it 'queries attendees by condition' do
      results = service.query(response_status: 'accepted')
      expect(results.size).to eq(1)
      expect(results.first[:email]).to eq('query@example.com')
    end
  end
end
