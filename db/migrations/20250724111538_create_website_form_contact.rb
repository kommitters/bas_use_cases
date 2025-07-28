# frozen_string_literal: true

Sequel.migration do
  change do
    create_table?(:website_form_contact) do
      primary_key :id
      Jsonb :data
      String :tag, size: 255
      TrueClass :archived
      String :stage, size: 255
      String :status, size: 255
      Jsonb :error_message
      String :version, size: 255
      DateTime :inserted_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
