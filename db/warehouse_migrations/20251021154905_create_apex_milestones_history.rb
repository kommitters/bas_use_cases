# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:apex_milestones_history) do
      uuid :id, primary_key: true, default: Sequel.lit('gen_random_uuid()')
      String :external_apex_milestone_id, size: 255, null: false
      foreign_key :apex_milestone_id, :apex_milestones, type: :uuid
      foreign_key :kr_id, :krs, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 2000, null: false
      Integer :milestone_order, null: false
      Float :percentage, null: true
      Date :completion_date, null: true
      Boolean :is_completed, default: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  down do
    drop_table(:apex_milestones_history)
  end
end
