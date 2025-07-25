# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:calendar_event_attendees) do
      add_foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :set_null
      drop_column :email
    end
  end

  down do
    alter_table(:calendar_event_attendees) do
      drop_column :person_id
      add_column :email, String, size: 255, null: false
    end
  end
end
