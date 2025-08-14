# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:kpis) do
      set_column_type :description, String, size: 1000
    end

    alter_table(:kpis_history) do
      set_column_type :description, String, size: 1000
    end
  end

  down do
    alter_table(:kpis) do
      set_column_type :description, String, size: 255
    end

    alter_table(:kpis_history) do
      set_column_type :description, String, size: 255
    end
  end
end
