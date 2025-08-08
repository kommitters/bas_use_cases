# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:document_activity_logs) do
      add_column :unique_identifier, String, size: 255, null: false, unique: true
    end
  end

  down do
    alter_table(:document_activity_logs) do
      drop_column :unique_identifier
    end
  end
end
