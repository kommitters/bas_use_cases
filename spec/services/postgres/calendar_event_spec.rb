# frozen_string_literal: true

require 'sequel'
require 'rspec'
require_relative '../../../src/services/postgres/base'
require_relative '../../../src/services/postgres/calendar_event'
require_relative '../../../src/services/postgres/calendar_event_attendee'
require_relative '../../../src/services/postgres/person'
require_relative 'test_db_helpers'

RSpec.describe Services::Postgres::CalendarEvent do
  include TestDBHelpers

  let(:db) { Sequel.sqlite }
  let(:config) { { adapter: 'sqlite', database: ':memory:' } }
  let(:service) { described_class.new(config) }
  let(:attendee_service) { Services::Postgres::CalendarEventAttendee.new(service.db) }
  let(:person_service) { Services::Postgres::Person.new(service.db) }

  before(:each) do
    db.drop_table?(:calendar_event_attendees)
    db.drop_table?(:persons)
    db.drop_table?(:domains)
    db.drop_table?(:calendar_events)

    create_calendar_events_table(db)
    create_calendar_event_attendees_table(db)
    create_persons_table(db)
    create_domains_table(db)

    allow_any_instance_of(Services::Postgres::Base).to receive(:establish_connection).and_return(db)
  end

  describe '#insert' do
    it 'creates a new calendar_event and returns its ID' do
      person_one_id = person_service.insert(external_person_id: 'ext-p-1',
                                            full_name: 'Jane Doe',
                                            email_address: 'jane@example.com')
      person_two_id = person_service.insert(external_person_id: 'ext-p-2',
                                            full_name: 'Other',
                                            email_address: 'other@example.com')

      params = {
        external_calendar_event_id: 'evt-123',
        summary: 'Test Event',
        duration_minutes: 60,
        start_time: Time.now,
        end_time: Time.now + 3600,
        creation_timestamp: Time.now - 86_400,
        attendees: [
          { email_address: 'jane@example.com', response_status: 'accepted' },
          { email_address: 'other@example.com', response_status: 'declined' }
        ]
      }
      id = service.insert(params)
      event = service.find(id)
      attendees = attendee_service.query(calendar_event_id: id)

      expect(event[:summary]).to eq('Test Event')
      expect(event[:external_calendar_event_id]).to eq('evt-123')
      expect(event[:duration_minutes]).to eq(60)

      expect(attendees.size).to eq(2)

      attendee_person_ids = attendees.map { |a| a[:person_id] }
      expect(attendee_person_ids).to contain_exactly(person_one_id, person_two_id)

      emails = attendee_person_ids.map do |pid|
        person_service.find(pid)[:email_address]
      end
      expect(emails).to contain_exactly('jane@example.com', 'other@example.com')
    end

    it 'handles attendees with unknown email addresses gracefully' do
      person_service.insert(
        external_person_id: 'ext-p-1',
        full_name: 'Jane Doe',
        email_address: 'jane@example.com'
      )

      params = {
        external_calendar_event_id: 'evt-123',
        summary: 'Test Event',
        duration_minutes: 60,
        start_time: Time.now,
        end_time: Time.now + 3600,
        creation_timestamp: Time.now - 86_400,
        attendees: [
          { email_address: 'jane@example.com', response_status: 'accepted' },
          { email_address: 'unknown@example.com', response_status: 'declined' }
        ]
      }
      # Should either skip unknown attendees or handle gracefully
      expect { service.insert(params) }.not_to raise_error
    end
  end

  describe '#update' do
    let(:person_one_id) do
      person_service.insert(
        external_person_id: 'ext-p-1',
        full_name: 'Jane Doe',
        email_address: 'jane@example.com'
      )
    end

    let(:person_two_id) do
      person_service.insert(
        external_person_id: 'ext-p-2',
        full_name: 'Other',
        email_address: 'other@example.com'
      )
    end

    let!(:person_three_id) do
      person_service.insert(
        external_person_id: 'ext-p-3',
        full_name: 'New Person',
        email_address: 'new@example.com'
      )
    end

    let(:event_id) do
      service.insert(
        external_calendar_event_id: 'evt-to-update',
        summary: 'Old Summary',
        duration_minutes: 30,
        start_time: Time.now,
        end_time: Time.now + 1800,
        creation_timestamp: Time.now - 86_400,
        attendees: [
          { email_address: 'jane@example.com', response_status: 'accepted' },
          { email_address: 'other@example.com', response_status: 'declined' }
        ]
      )
    end

    it 'updates a calendar_event by ID including attendees' do
      service.update(
        event_id,
        {
          summary: 'Updated Summary',
          duration_minutes: 45,
          attendees: [
            { email_address: 'new@example.com', response_status: 'tentative' }
          ]
        }
      )
      updated = service.find(event_id)
      attendees = attendee_service.query(calendar_event_id: event_id)

      expect(updated[:summary]).to eq('Updated Summary')
      expect(updated[:duration_minutes]).to eq(45)

      expect(attendees.size).to eq(1)
      expect(attendees.first[:response_status]).to eq('tentative')

      expect(attendees.first[:person_id]).to eq(person_three_id)
    end

    it 'raises an error if no ID is provided' do
      expect { service.update(nil, { summary: 'No ID' }) }.to raise_error(ArgumentError)
    end
  end

  describe '#delete' do
    it 'deletes a calendar_event by ID and its attendees' do
      person_service.insert(external_person_id: 'ext-p-1', full_name: 'Jane Doe', email_address: 'jane@example.com')

      id = service.insert(
        external_calendar_event_id: 'evt-to-delete',
        summary: 'To Delete',
        duration_minutes: 15,
        start_time: Time.now,
        end_time: Time.now,
        creation_timestamp: Time.now,
        attendees: [
          { email_address: 'jane@example.com', response_status: 'accepted' }
        ]
      )

      expect { service.delete(id) }.to change { service.query.size }.by(-1)

      attendees = attendee_service.query(calendar_event_id: id)
      expect(attendees).to be_empty

      expect(service.find(id)).to be_nil
    end
  end

  describe '#find' do
    it 'finds a calendar_event by ID and returns attendees' do
      person_service.insert(external_person_id: 'ext-p-1', full_name: 'Jane Doe', email_address: 'jane@example.com')
      person_service.insert(external_person_id: 'ext-p-2', full_name: 'Other', email_address: 'other@example.com')

      id = service.insert(
        external_calendar_event_id: 'evt-to-find',
        summary: 'Find Me',
        duration_minutes: 10,
        start_time: Time.now,
        end_time: Time.now,
        creation_timestamp: Time.now,
        attendees: [
          { email_address: 'jane@example.com', response_status: 'accepted' },
          { email_address: 'other@example.com', response_status: 'declined' }
        ]
      )
      found = service.find(id)
      attendees = attendee_service.query(calendar_event_id: id)

      expect(found[:id]).to eq(id)
      expect(found[:summary]).to eq('Find Me')
      expect(attendees.size).to eq(2)

      attendee_emails = attendees.map { |a| person_service.find(a[:person_id])[:email_address] }
      expect(attendee_emails).to contain_exactly('jane@example.com', 'other@example.com')
    end
  end

  describe '#query' do
    before do
      person_service.insert(external_person_id: 'ext-p-1', full_name: 'Jane Doe', email_address: 'jane@example.com')
      person_service.insert(external_person_id: 'ext-p-2', full_name: 'Other', email_address: 'other@example.com')

      service.insert(
        external_calendar_event_id: 'evt-query-1',
        summary: 'Query Me',
        duration_minutes: 5,
        start_time: Time.now,
        end_time: Time.now,
        creation_timestamp: Time.now,
        attendees: [
          { email_address: 'jane@example.com', response_status: 'accepted' }
        ]
      )
      service.insert(
        external_calendar_event_id: 'evt-query-2',
        summary: 'Another Event',
        duration_minutes: 25,
        start_time: Time.now,
        end_time: Time.now,
        creation_timestamp: Time.now,
        attendees: [
          { email_address: 'other@example.com', response_status: 'accepted' }
        ]
      )
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
