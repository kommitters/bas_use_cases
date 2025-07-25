# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require 'bas/shared_storage/default'
require 'bas/shared_storage/postgres'
require_relative '../../../../src/implementations/fetch_workspace_calendar_events'
require_relative '../../../../src/services/google_workspace/reports'
require_relative '../../../../src/utils/warehouse/google_workspace/calendar_events_format'

RSpec.describe Implementation::FetchWorkspaceCalendarEvents do
  subject(:bot) { described_class.new(options, shared_storage_reader, shared_storage_writer) }

  let(:options) { { google_keyfile_path: 'fake_path', google_admin_email: 'fake_admin' } }

  let(:shared_storage_reader) { instance_double(Bas::SharedStorage::Default) }
  let(:shared_storage_writer) { instance_double(Bas::SharedStorage::Postgres) }
  let(:reports_service) { instance_double(Services::GoogleWorkspace::Reports) }
  let(:formatter) { instance_double('Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter') }

  let(:activity1_for_event1) do
    OpenStruct.new(events: [OpenStruct.new(name: 'create_event',
                                           parameters: [OpenStruct.new(
                                             name: 'event_id', value: 'event1'
                                           )])])
  end
  let(:activity2_for_event1) do
    OpenStruct.new(events: [OpenStruct.new(name: 'change_event_title',
                                           parameters: [OpenStruct.new(
                                             name: 'event_id', value: 'event1'
                                           )])])
  end
  let(:activity1_for_event2) do
    OpenStruct.new(events: [OpenStruct.new(name: 'create_event',
                                           parameters: [OpenStruct.new(
                                             name: 'event_id', value: 'event2'
                                           )])])
  end

  let(:all_activities) { [activity1_for_event1, activity2_for_event1, activity1_for_event2] }
  let(:formatted_event) { { id: 'formatted_event' } }

  before do
    allow(bot).to receive(:read_response).and_return(OpenStruct.new(inserted_at: nil))
    allow(Services::GoogleWorkspace::Reports).to receive(:new).and_return(reports_service)
    allow(Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter).to receive(:new).and_return(formatter)
    allow(formatter).to receive(:format).and_return(formatted_event)
  end

  describe '#process' do
    context 'when the Google API call fails' do
      before do
        allow(bot).to receive(:read_response).and_return(nil)
        allow(reports_service).to receive(:fetch_calendar_activities).and_return({ error: { message: 'API Error' } })
      end

      it 'returns an error hash' do
        result = bot.process
        expect(result).to eq({ error: { message: 'API Error' } })
      end
    end

    context 'when the Google API call is successful' do
      before do
        allow(reports_service).to receive(:fetch_calendar_activities)
          .and_return({ success: { activities: all_activities } })
      end

      context 'and it is the first run' do
        before { allow(bot).to receive(:read_response).and_return(nil) }

        it 'requests activities using the default start date' do
          expect(reports_service).to receive(:fetch_calendar_activities)
            .with(start_time: described_class::DEFAULT_START_DATE)
          bot.process
        end
      end

      context 'and it is a subsequent run' do
        let(:last_run_time) { Time.parse('2025-07-20T10:00:00Z') }
        let(:last_run_response) { OpenStruct.new(inserted_at: last_run_time) }

        before { allow(bot).to receive(:read_response).and_return(last_run_response) }

        it 'requests activities using the last run timestamp' do
          expect(reports_service).to receive(:fetch_calendar_activities).with(start_time: last_run_time)
          bot.process
        end
      end

      it 'formats the activities and returns a success response' do
        allow(bot).to receive(:read_response).and_return(nil)
        result = bot.process

        expect(Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter).to have_received(:new).twice
        expect(formatter).to have_received(:format).twice

        expect(result).to eq({ success: { type: 'calendar_event', content: [formatted_event, formatted_event] } })
      end
    end

    context 'when the Google API returns no activities' do
      before do
        allow(bot).to receive(:read_response).and_return(nil)
        allow(reports_service).to receive(:fetch_calendar_activities).and_return({ success: { activities: [] } })
      end

      it 'returns a success response with empty content' do
        result = bot.process
        expect(result).to eq({ success: { type: 'calendar_event', content: [] } })
      end
    end
  end
end
