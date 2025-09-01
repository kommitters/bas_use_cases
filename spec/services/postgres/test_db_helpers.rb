# frozen_string_literal: true

require 'securerandom'
module TestDBHelpers # rubocop:disable Metrics/ModuleLength
  def create_projects_table(db)
    db.create_table(:projects) do
      primary_key :id
      String :external_project_id, null: false
      String :name, null: false
      String :status, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_activities_table(db)
    db.create_table(:activities) do
      primary_key :id
      String :external_activity_id, null: false
      String :name, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_domains_table(db)
    db.create_table(:domains) do
      primary_key :id
      String :external_domain_id, null: false
      String :name, null: false
      Boolean :archived, default: false, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_persons_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:persons) do
      primary_key :id
      String :external_person_id, null: false
      String :full_name, null: false
      String :email_address, null: true
      String :role, null: true
      Boolean :is_active, null: true
      DateTime :hire_date, null: true
      DateTime :exit_date, null: true
      String :github_username, null: true
      Integer :notion_user_id, null: true
      Integer :worklogs_user_id, null: true
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_work_items_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:work_items) do
      primary_key :id
      String :external_work_item_id, null: false
      String :name, null: false
      String :status, null: false
      DateTime :completion_date
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      foreign_key :activity_id, :activities, type: :uuid, null: true, on_delete: :cascade
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :cascade
      foreign_key :weekly_scope_id, :weekly_scopes, type: :uuid, null: true, on_delete: :cascade
      foreign_key :github_issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_milestones_table(db)
    db.create_table(:milestones) do
      primary_key :id
      String :external_milestone_id, null: false
      String :name, null: false
      String :status, null: false
      DateTime :completion_date
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_documents_table(db)
    db.create_table(:documents) do
      primary_key :id
      String :name, null: false
      String :external_document_id, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_document_activity_logs_table(db)
    db.create_table(:document_activity_logs) do
      primary_key :id
      foreign_key :document_id, :documents, type: :uuid, null: false, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :cascade
      String :action, size: 255, null: false
      jsonb :details, null: false, default: '{}'
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_weekly_scopes_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:weekly_scopes) do
      primary_key :id
      String :external_weekly_scope_id, null: false
      String :description, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :cascade
      DateTime :start_week_date
      DateTime :end_week_date
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_key_results_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:key_results) do
      primary_key :id
      String :external_key_result_id, null: false
      String :okr, null: false
      String :key_result, null: false
      Float :metric, null: false
      Float :current, null: false
      Float :progress, null: false
      String :period, null: false
      String :objective, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_key_results_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:key_results_history) do
      primary_key :id
      Integer :key_result_id
      String :external_key_result_id, null: false
      String :okr, null: false
      String :key_result, null: false
      Float :metric, null: false
      Float :current, null: false
      Float :progress, null: false
      String :period, null: false
      String :objective, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_activities_key_results_table(db)
    db.create_table(:activities_key_results) do
      primary_key :id
      foreign_key :activity_id, :activities, type: :uuid, on_delete: :cascade
      foreign_key :key_result_id, :key_results, type: :uuid, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_work_logs_table(db) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    db.create_table :work_logs do
      primary_key :id
      String :external_work_log_id, size: 255, null: false
      Integer :duration_minutes, null: false
      column :tags, 'text[]', null: true
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      foreign_key :activity_id, :activities, type: :uuid, null: true, on_delete: :cascade
      foreign_key :work_item_id, :work_items, type: :uuid, null: true, on_delete: :cascade
      DateTime :creation_date, null: false
      DateTime :modification_date, null: true
      TrueClass :external, null: true
      TrueClass :deleted, null: true
      DateTime :started_at, null: false
      String :description, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_github_releases_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:github_releases) do
      primary_key :id
      BigInt :external_github_release_id, null: false
      BigInt :repository_id, null: false
      String :name, size: 255, null: true
      String :tag_name, size: 255, null: false
      Boolean :is_prerelease, null: false, default: false
      DateTime :creation_timestamp, null: false
      DateTime :published_timestamp, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_github_issues_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:github_issues) do
      primary_key :id
      BigInt :external_github_issue_id, null: false
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      BigInt :repository_id, null: false
      BigInt :milestone_id, null: true
      column :assignees, 'text[]', null: true
      column :labels, 'text[]', null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_github_pull_requests_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:github_pull_requests) do
      primary_key :id
      BigInt :external_github_pull_request_id, null: false
      BigInt :repository_id, null: false
      foreign_key :release_id, :github_releases, type: :uuid, null: false, on_delete: :cascade
      foreign_key :issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
      column :related_issue_ids, 'bigint[]', null: true
      column :reviews_data, :jsonb, null: true
      String :title, size: 255, null: false
      DateTime :creation_date, null: false
      DateTime :merge_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_calendar_events_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:calendar_events) do
      primary_key :id
      String :external_calendar_event_id, size: 255, null: false
      String :summary, size: 1000, null: true
      Integer :duration_minutes, null: false
      DateTime :start_time, null: false
      DateTime :end_time, null: false
      DateTime :creation_timestamp, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_calendar_event_attendees_table(db)
    db.create_table(:calendar_event_attendees) do
      primary_key :id
      foreign_key :calendar_event_id, :calendar_events, type: :uuid, null: false, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :cascade
      String :response_status, size: 50, null: false
    end
  end

  def create_kpis_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:kpis) do
      primary_key :id
      String :external_kpi_id, size: 255, null: true
      foreign_key :domain_id, :domains, type: :uuid, null: false, on_delete: :cascade
      String :description, size: 255, null: true
      String :status, size: 255, null: true
      Float :current_value, null: true
      Float :percentage, null: true
      Float :target_value, null: true
      jsonb :stats, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_kpis_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:kpis_history) do
      primary_key :id
      foreign_key :kpi_id, :kpis, type: :uuid, null: false, on_delete: :cascade
      String :external_kpi_id, size: 255, null: true
      foreign_key :domain_id, :domains, type: :uuid, null: false, on_delete: :cascade
      String :description, size: 255, null: true
      String :status, size: 255, null: true
      Float :current_value, null: true
      Float :percentage, null: true
      Float :target_value, null: true
      jsonb :stats, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_activities_history_table(db)
    db.create_table(:activities_history) do
      primary_key :id
      String :external_activity_id, null: false
      foreign_key :activity_id, :activities, type: :uuid, null: false, on_delete: :cascade
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      String :name, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_calendar_events_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:calendar_events_history) do
      primary_key :id
      String :external_calendar_event_id, size: 255, null: false
      foreign_key :calendar_event_id, :calendar_events, type: :uuid, null: false, on_delete: :cascade
      String :summary, size: 1000, null: true
      Integer :duration_minutes, null: false
      DateTime :start_time, null: false
      DateTime :end_time, null: false
      DateTime :creation_timestamp, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_documents_history_table(db)
    db.create_table(:documents_history) do
      primary_key :id
      foreign_key :document_id, :documents, type: :uuid, null: false, on_delete: :cascade
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      String :external_document_id, null: false
      String :name, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_domains_history_table(db)
    db.create_table(:domains_history) do
      primary_key :id
      String :external_domain_id, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: false, on_delete: :cascade
      String :name, null: false
      Boolean :archived, default: false, null: false
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_github_releases_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:github_releases_history) do
      primary_key :id
      foreign_key :release_id, :github_releases, type: :uuid, null: false, on_delete: :cascade
      BigInt :external_github_release_id, null: false
      BigInt :repository_id, null: false
      String :name, size: 255, null: true
      String :tag_name, size: 255, null: false
      Boolean :is_prerelease, null: false, default: false
      DateTime :creation_timestamp, null: false
      DateTime :published_timestamp, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_github_issues_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:github_issues_history) do
      primary_key :id
      BigInt :external_github_issue_id, null: false
      foreign_key :issue_id, :github_issues, type: :uuid, null: false, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      BigInt :repository_id, null: false
      BigInt :milestone_id, null: true
      column :assignees, 'text[]', null: true
      column :labels, 'text[]', null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_github_pull_requests_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:github_pull_requests_history) do
      primary_key :id
      BigInt :external_github_pull_request_id, null: false
      foreign_key :pull_request_id, :github_pull_requests, type: :uuid, null: false, on_delete: :cascade
      foreign_key :release_id, :github_releases, type: :uuid, null: false, on_delete: :cascade
      foreign_key :issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
      BigInt :repository_id, null: false
      column :related_issue_ids, 'bigint[]', null: true
      column :reviews_data, :jsonb, null: true
      String :title, size: 255, null: false
      DateTime :creation_date, null: false
      DateTime :merge_date, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_milestones_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:milestones_history) do
      primary_key :id
      String :external_milestone_id, null: false
      foreign_key :milestone_id, :milestones, type: :uuid, null: false, on_delete: :cascade
      String :name, null: false
      String :status, null: false
      DateTime :completion_date
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_persons_history_table(db) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    db.create_table(:persons_history) do
      primary_key :id
      String :external_person_id, null: false
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      String :full_name, null: false
      String :email_address, null: true
      String :role, null: true
      Boolean :is_active, null: true
      DateTime :hire_date, null: true
      DateTime :exit_date, null: true
      String :github_username, null: true
      Integer :notion_user_id, null: true
      Integer :worklogs_user_id, null: true
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_projects_history_table(db)
    db.create_table(:projects_history) do
      primary_key :id
      String :external_project_id, null: false
      foreign_key :project_id, :projects, type: :uuid, null: false, on_delete: :cascade
      String :name, null: false
      String :status, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_weekly_scopes_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:weekly_scopes_history) do
      primary_key :id
      String :external_weekly_scope_id, null: false
      foreign_key :weekly_scope_id, :weekly_scopes, type: :uuid, null: false, on_delete: :cascade
      String :description, null: false
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :cascade
      DateTime :start_week_date
      DateTime :end_week_date
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_work_items_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:work_items_history) do
      primary_key :id
      String :external_work_item_id, null: false
      foreign_key :work_item_id, :work_items, type: :uuid, null: false, on_delete: :cascade
      String :name, null: false
      String :status, null: false
      DateTime :completion_date
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      foreign_key :activity_id, :activities, type: :uuid, null: true, on_delete: :cascade
      foreign_key :domain_id, :domains, type: :uuid, null: true, on_delete: :cascade
      foreign_key :person_id, :persons, type: :uuid, null: true, on_delete: :cascade
      foreign_key :weekly_scope_id, :weekly_scopes, type: :uuid, null: true, on_delete: :cascade
      foreign_key :github_issue_id, :github_issues, type: :uuid, null: true, on_delete: :cascade
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_work_logs_history_table(db) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize
    db.create_table(:work_logs_history) do
      primary_key :id
      String :external_work_log_id, size: 255, null: false
      foreign_key :work_log_id, :work_logs, type: :uuid, null: false, on_delete: :cascade
      Integer :duration_minutes, null: false
      column :tags, 'text[]', null: true
      foreign_key :person_id, :persons, type: :uuid, null: false, on_delete: :cascade
      foreign_key :project_id, :projects, type: :uuid, null: true, on_delete: :cascade
      foreign_key :activity_id, :activities, type: :uuid, null: true, on_delete: :cascade
      foreign_key :work_item_id, :work_items, type: :uuid, null: true, on_delete: :cascade
      DateTime :creation_date, null: false
      DateTime :modification_date, null: true
      TrueClass :external, null: true
      TrueClass :deleted, null: true
      DateTime :started_at, null: false
      String :description, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end
end
