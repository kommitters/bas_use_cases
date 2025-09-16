# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:work_items) do
      set_column_allow_null :description, true
      set_column_type :description, String, size: 1000
    end

    alter_table(:work_items_history) do
      set_column_allow_null :description, true
      set_column_type :description, String, size: 1000
    end
  end

  down do
    alter_table(:work_items) do
      set_column_type :description, String, size: 255
      set_column_allow_null :description, false
    end

    alter_table(:work_items_history) do
      set_column_type :description, String, size: 255
      set_column_allow_null :description, false
    end
  end
end
