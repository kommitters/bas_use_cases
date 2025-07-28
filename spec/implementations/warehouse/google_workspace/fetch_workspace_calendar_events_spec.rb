# frozen_string_literal: true

require 'spec_helper'
require 'bas/shared_storage/postgres'
require_relative '../../../../src/implementations/fetch_workspace_calendar_events'
require_relative '../../../../src/utils/warehouse/google_workspace/calendar_events_format'
require_relative 'mock_data_helper'

RSpec.describe Implementation::FetchWorkspaceCalendarEvents do
  subject(:bot) { described_class.new(options, shared_storage) }

  let(:shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:formatter) { instance_double('Utils::Warehouse::GoogleWorkspace::CalendarEventsFormatter') }
  let(:formatted_event) { { id: 'formatted_event' } }

  let(:all_activities) { MockData.generate_calendar_events }

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
