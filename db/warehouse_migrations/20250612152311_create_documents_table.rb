# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:documents) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :name, size: 255, null: false
      String :external_document_id, size: 255, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:documents)
  end
end
