# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:calendar_events) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_calendar_event_id, size: 255, null: false
      String :summary, size: 1000, null: true
      Integer :duration_minutes, null: false
      DateTime :start_time, null: false
      DateTime :end_time, null: false
      DateTime :creation_timestamp, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:calendar_events)
  end
end
