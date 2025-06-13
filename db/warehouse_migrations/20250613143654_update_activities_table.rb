# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:activities) do
      drop_column :external_domain_id
      add_foreign_key :domain_id, :domains, type: :uuid, null: true
    end
  end

  down do
    alter_table(:activities) do
      drop_foreign_key :domain_id
      add_column :external_domain_id, String, size: 255, null: true
    end
  end
end
