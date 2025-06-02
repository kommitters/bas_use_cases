# frozen_string_literal: true

Sequel.migration do
  up do
    create_table?(:observed_websites_availability) do
      primary_key :id
      column :data, :jsonb
      String :tag, size: 255
      TrueClass :archived
      String :stage, size: 255
      String :status, size: 255
      column :error_message, :jsonb
      String :version, size: 255
      DateTime :inserted_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table?(:observed_websites_availability)
  end
end
