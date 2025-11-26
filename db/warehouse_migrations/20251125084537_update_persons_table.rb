# frozen_string_literal: true

Sequel.migration do # rubocop:disable Metrics/BlockLength
  up do
    alter_table(:persons) do
      drop_constraint :persons_domain_id_fkey

      drop_column :domain_id
      drop_column :notion_user_id

      add_foreign_key :org_unit_id, :organizational_units, type: :uuid, null: true, on_delete: :cascade

      add_column :job_title, String, null: true
    end

    alter_table(:persons_history) do
      drop_column :domain_id

      add_column :org_unit_id, :uuid, null: true
      add_column :job_title, String, null: true
    end
  end

  down do
    alter_table(:persons) do
      drop_column :organizational_unit_id
      drop_column :job_title

      add_foreign_key :domain_id, :domains, type: :uuid, null: true

      add_column :notion_user_id, String, null: true
    end

    alter_table(:persons_history) do
      drop_column :org_unit_id
      drop_column :job_title

      add_column :domain_id, :uuid, null: true
    end
  end
end
