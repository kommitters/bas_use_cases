# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:work_items) do
      add_foreign_key :weekly_scope_id, :weekly_scopes, type: :uuid
      drop_column :external_weekly_scope_id
    end
  end

  down do
    alter_table(:work_items) do
      drop_foreign_key :weekly_scope_id
    end
  end
end
