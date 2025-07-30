# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:document_activity_logs) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      foreign_key :document_id, :documents, type: :uuid, null: false
      foreign_key :person_id, :persons, type: :uuid, null: true
      String :action, size: 255, null: false
      jsonb :details, null: false, default: '{}'
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:document_activity_logs)
  end
end
