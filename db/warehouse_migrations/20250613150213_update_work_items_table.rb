# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:work_items) do
      drop_column :external_domain_id
      rename_column :work_item_status, :status
      rename_column :work_item_completion_date, :completion_date
      add_column :description, String, size: 255, null: false
      add_foreign_key :domain_id, :domains, type: :uuid, null: true
      add_foreign_key :person_id, :persons, type: :uuid, null: true
    end
  end

  down do
    alter_table(:work_items) do
      drop_foreign_key :domain_id
      drop_foreign_key :person_id
      drop_column :description
      rename_column :status, :work_item_status
      rename_column :completion_date, :work_item_completion_date
      add_column :external_domain_id, String, size: 255, null: true
    end
  end
end
