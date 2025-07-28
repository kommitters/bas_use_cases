# frozen_string_literal: true

# This file provides a diverse set of mock data for testing.
module MockData
  Parameter = Struct.new(:name, :value, :int_value)
  Event = Struct.new(:name, :parameters)
  ActivityId = Struct.new(:time, :unique_qualifier)
  Activity = Struct.new(:id, :events)

  def self.generate_calendar_events
    create_complex_alpha_event + create_simple_meeting + create_planning_session_event
  end

  class << self
    private

    def create_complex_alpha_event # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      event_id = 'evt_project_alpha'
      [

        Activity.new(
          ActivityId.new(Time.now.to_s, 'alpha1'),
          [Event.new('create_event', [
                       Parameter.new('event_id', event_id, nil),
                       Parameter.new('event_title', 'Initial Review', nil),
                       Parameter.new('event_guest', 'user1@example.com', nil),
                       Parameter.new('event_guest', 'user2@example.com', nil),
                       Parameter.new('start_time', nil, 63_900_100_000),
                       Parameter.new('end_time', nil, 63_900_103_600)
                     ])]
        ),

        Activity.new(
          ActivityId.new(Time.now.to_s, 'alpha2'),
          [Event.new('change_event_title', [
                       Parameter.new('event_id', event_id, nil),
                       Parameter.new('event_title', 'Final Review Project Alpha', nil)
                     ])]
        ),

        Activity.new(
          ActivityId.new(Time.now.to_s, 'alpha3'),
          [Event.new('change_event_guest_response', [
                       Parameter.new('event_id', event_id, nil),
                       Parameter.new('event_guest', 'user1@example.com', nil),
                       Parameter.new('event_response_status', 'accepted', nil)
                     ])]
        ),
        Activity.new(
          ActivityId.new(Time.now.to_s, 'alpha4'),
          [Event.new('change_event_guest_response', [
                       Parameter.new('event_id', event_id, nil),
                       Parameter.new('event_guest', 'user2@example.com', nil),
                       Parameter.new('event_response_status', 'declined', nil)
                     ])]
        )
      ]
    end

    def create_simple_meeting # rubocop:disable Metrics/MethodLength
      [
        Activity.new(
          ActivityId.new(Time.now.to_s, 'simple1'),
          [Event.new('create_event', [
                       Parameter.new('event_id', 'evt_simple_meeting', nil),
                       Parameter.new('event_title', 'Quick Sync', nil),
                       Parameter.new('start_time', nil, 63_900_200_000),
                       Parameter.new('end_time', nil, 63_900_201_800)
                     ])]
        )
      ]
    end

    def create_planning_session_event # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      event_id = 'evt_planning_session'
      [
        Activity.new(
          ActivityId.new(Time.now.to_s, 'planning1'),
          [Event.new('create_event', [
                       Parameter.new('event_id', event_id, nil),
                       Parameter.new('event_title', 'Q4 Planning', nil),
                       Parameter.new('event_guest', 'manager@example.com', nil),
                       Parameter.new('start_time', nil, 63_900_300_000),
                       Parameter.new('end_time', nil, 63_900_305_400)
                     ])]
        ),
        Activity.new(
          ActivityId.new(Time.now.to_s, 'planning2'),
          [Event.new('change_event_guest_response', [
                       Parameter.new('event_id', event_id, nil),
                       Parameter.new('event_guest', 'manager@example.com', nil),
                       Parameter.new('event_response_status', 'tentative', nil)
                     ])]
        )
      ]
    end
  end
end
