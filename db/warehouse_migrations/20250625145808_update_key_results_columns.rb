# frozen_string_literal: true

Sequel.migration do # rubocop:disable Metrics/BlockLength
  up do
    alter_table(:key_results) do
      set_column_allow_null :metric
      set_column_allow_null :current
      set_column_allow_null :progress
      set_column_allow_null :period
      set_column_allow_null :objective
      set_column_allow_null :key_result
      set_column_allow_null :okr
      set_column_not_null :external_key_result_id

      add_column :tags, String, size: 255, null: true
    end
  end

  down do
    alter_table(:key_results) do
      set_column_not_null :metric
      set_column_not_null :current
      set_column_not_null :progress
      set_column_not_null :period
      set_column_not_null :objective
      set_column_not_null :key_result
      set_column_not_null :okr
      set_column_allow_null :external_key_result_id

      drop_column :tags
    end
  end
end
