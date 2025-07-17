# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:calendar_event_attendees) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      foreign_key :calendar_event_id, :calendar_events, type: :uuid, null: false, on_delete: :cascade
      String :email, size: 255, null: false
      String :response_status, size: 50, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:calendar_event_attendees)
  end
end
