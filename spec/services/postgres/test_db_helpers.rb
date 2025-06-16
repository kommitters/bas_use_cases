# frozen_string_literal: true

module TestDBHelpers
  def create_projects_table(db)
    db.create_table(:projects) do
      primary_key :id
      String :external_project_id, null: false
      String :name, null: false
      String :status, null: false
      Integer :domain_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_activities_table(db)
    db.create_table(:activities) do
      primary_key :id
      String :external_activity_id, null: false
      String :name, null: false
      Integer :domain_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_domains_table(db)
    db.create_table(:domains) do
      primary_key :id
      String :external_domain_id, null: false
      String :name, null: false
      Boolean :archived, default: false, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_persons_table(db)
    db.create_table(:persons) do
      primary_key :id
      String :external_person_id, null: false
      String :name, null: false
      Integer :domain_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_work_items_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:work_items) do
      primary_key :id
      String :external_work_item_id, null: false
      String :name, null: false
      String :status, null: false
      DateTime :completion_date
      Integer :project_id
      Integer :activity_id
      Integer :domain_id
      Integer :person_id
      Integer :weekly_scope_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_milestones_table(db)
    db.create_table(:milestones) do
      primary_key :id
      String :external_milestone_id, null: false
      String :name, null: false
      String :status, null: false
      DateTime :completion_date
      Integer :project_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_documents_table(db)
    db.create_table(:documents) do
      primary_key :id
      String :name, null: false
      String :external_document_id, null: false
      Integer :domain_id
      DateTime :created_at
      DateTime :updated_at
    end
  end

  def create_weekly_scope_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:weekly_scopes) do
      primary_key :id
      String :external_weekly_scope_id, null: false
      String :description, null: false
      Integer :domain_id
      Integer :person_id
      DateTime :start_week_date
      DateTime :end_week_date
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
