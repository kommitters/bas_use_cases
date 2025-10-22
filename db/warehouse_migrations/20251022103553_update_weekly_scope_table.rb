# frozen_string_literal: true

Sequel.migration do # rubocop:disable Metrics/BlockLength
  up do
    alter_table(:weekly_scopes) do
      drop_constraint :weekly_scopes_domain_id_fkey
      drop_constraint :weekly_scopes_person_id_fkey

      drop_column :domain_id
      drop_column :person_id

      set_column_allow_null :description, true
    end

    alter_table(:weekly_scopes_history) do
      drop_column :domain_id
      drop_column :person_id

      set_column_allow_null :description, true
    end
  end

  down do
    alter_table(:weekly_scopes) do
      add_foreign_key :domain_id, :domains, type: :uuid, null: true
      add_foreign_key :person_id, :persons, type: :uuid, null: true

      set_column_allow_null :description, false
    end

    alter_table(:weekly_scopes_history) do
      add_column :domain_id, :uuid, null: true
      add_column :person_id, :uuid, null: true

      set_column_allow_null :description, false
    end
  end
end
