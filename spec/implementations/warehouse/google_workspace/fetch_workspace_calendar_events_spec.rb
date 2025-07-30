# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require_relative '../../../../src/implementations/fetch_workspace_calendar_events'
require_relative '../../../../src/utils/warehouse/google_workspace/calendar_events_format'

RSpec.describe Implementation::FetchWorkspaceCalendarEvents do
  subject(:bot) { described_class.new(options, shared_storage) }

  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:formatter) { instance_double('Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter') }
  let(:formatted_event) { { id: 'formatted_event' } }

  let(:alpha_event_activities) do
    event_id = 'evt_project_alpha'
    [
      {
        'id' => { 'time' => Time.now.to_s },
        'events' => [{
          'name' => 'create_event',
          'parameters' => [
            { 'name' => 'event_id', 'value' => event_id },
            { 'name' => 'event_title', 'value' => 'Initial Review' },
            { 'name' => 'event_guest', 'value' => 'user1@example.com' },
            { 'name' => 'event_guest', 'value' => 'user2@example.com' },
            { 'name' => 'start_time', 'intValue' => '63900100000' },
            { 'name' => 'end_time', 'intValue' => '63900103600' }
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
      },
      {
        'id' => { 'time' => Time.now.to_s },
        'events' => [{
          'name' => 'change_event_guest_response',
          'parameters' => [
            { 'name' => 'event_id', 'value' => event_id },
            { 'name' => 'event_guest', 'value' => 'user1@example.com' },
            { 'name' => 'event_response_status', 'value' => 'accepted' }
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
          { 'name' => 'event_title', 'value' => 'Quick Sync' },
          { 'name' => 'start_time', 'intValue' => '63900200000' },
          { 'name' => 'end_time', 'intValue' => '63900201800' }
        ]
      }]
    }]
  end

  let(:planning_event_activity) do
    event_id = 'evt_planning_session'
    [
      {
        'id' => { 'time' => Time.now.to_s },
        'events' => [{
          'name' => 'create_event',
          'parameters' => [
            { 'name' => 'event_id', 'value' => event_id },
            { 'name' => 'event_title', 'value' => 'Q4 Planning' },
            { 'name' => 'event_guest', 'value' => 'manager@example.com' },
            { 'name' => 'start_time', 'intValue' => '63900300000' },
            { 'name' => 'end_time', 'intValue' => '63900305400' }
          ]
        }]
      },
      {
        'id' => { 'time' => Time.now.to_s },
        'events' => [{
          'name' => 'change_event_guest_response',
          'parameters' => [
            { 'name' => 'event_id', 'value' => event_id },
            { 'name' => 'event_guest', 'value' => 'manager@example.com' },
            { 'name' => 'event_response_status', 'value' => 'tentative' }
          ]
        }]
      }
    ]
  end

  let(:all_activities) { alpha_event_activities + simple_event_activity + planning_event_activity }

  before do
    allow(Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter).to receive(:new).and_return(formatter)
    allow(formatter).to receive(:format).and_return(formatted_event)
  end

  describe '#process' do
    context 'when valid calendar_events data is provided' do
      let(:options) { { calendar_events: all_activities } }

      it 'groups activities by event_id, formats them, and returns a success response' do
        result = bot.process

        expect(Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter).to have_received(:new).thrice
        expect(formatter).to have_received(:format).thrice
        expect(result).to eq({ success: { type: 'calendar_event',
                                          content: [formatted_event, formatted_event, formatted_event] } })
      end
    end

    context 'when an empty array of calendar_events is provided' do
      let(:options) { { calendar_events: [] } }

      it 'returns an error hash' do
        result = bot.process
        expect(result).to eq({ error: { message: 'Input data must be a non-empty Array.' } })
      end
    end

    context 'when calendar_events data is missing or invalid' do
      let(:options) { { calendar_events: nil } }

      it 'returns an error hash for missing data' do
        result = bot.process
        expect(result).to eq({ error:
        {
          message: 'Input data must be a non-empty Array.'
        } })
      end
    end
  end
end
