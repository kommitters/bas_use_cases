# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:domains_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_domain_id, size: 255, null: false
      foreign_key :domain_id, :domains, null: false, on_delete: :cascade, type: :uuid
      String :name, size: 255, null: false
      Boolean :archived, default: false, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:domains_history)
  end
end
