# frozen_string_literal: true

Sequel.migration do
  up do
    create_table?(:operaton_deployed_processes) do
      primary_key :id
      column :data, :jsonb
      String :tag, size: 255
      TrueClass :archived
      String :stage, size: 255
      String :status, size: 255
      column :error_message, :jsonb
      String :version, size: 255
      DateTime :inserted_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end

  down do
    drop_table?(:operaton_deployed_processes)
  end
end
