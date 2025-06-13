# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:projects) do
      drop_column :external_domain_id
      drop_column :external_weekly_scope_id
      drop_column :type
      add_column :status, String, size: 100, null: false
      add_foreign_key :domain_id, :domains, type: :uuid, null: true
    end
  end

  down do
    alter_table(:projects) do
      drop_foreign_key :domain_id
      drop_column :status
      add_column :type, String, size: 100, null: false
      add_column :external_weekly_scope_id, String, size: 255, null: true
      add_column :external_domain_id, String, size: 255, null: true
    end
  end
end
