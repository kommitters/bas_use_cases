# frozen_string_literal: true

require 'date'
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

  def create_weekly_scopes_table(db)
    db.create_table(:weekly_scopes) do
      primary_key :id
      String :external_weekly_scope_id, null: false
      String :description, null: false
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
      jsonb :tags, null: true
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

  def create_github_repositories_table(db) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    db.create_table(:github_repositories) do
      primary_key :id
      BigInt :external_github_repository_id, null: false
      String :name, null: false
      String :language, null: true
      String :description, null: true
      String :html_url, null: true

      Boolean :is_private, null: false, default: false
      Boolean :is_fork, null: false, default: false
      Boolean :is_archived, null: false, default: false
      Boolean :is_disabled, null: false, default: false

      Integer :watchers_count, null: false, default: 0
      Integer :stargazers_count, null: false, default: 0
      Integer :forks_count, null: false, default: 0

      jsonb :owner, null: true

      DateTime :creation_timestamp, null: false
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

  def create_weekly_scopes_history_table(db)
    db.create_table(:weekly_scopes_history) do
      primary_key :id
      String :external_weekly_scope_id, null: false
      foreign_key :weekly_scope_id, :weekly_scopes, type: :uuid, null: false, on_delete: :cascade
      String :description, null: false
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
      jsonb :tags, null: true
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

  def create_operaton_processes_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:operaton_processes) do
      primary_key :id
      String :external_process_id, null: false
      String :business_key
      String :process_definition_key
      String :process_definition_name
      DateTime :start_time
      DateTime :end_time
      Integer :duration_in_millis
      String :process_definition_version
      String :state
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_okrs_table(db)
    db.create_table(:okrs) do
      primary_key :id
      String :external_okr_id, size: 255, null: false
      String :code, size: 20, null: true
      String :status, size: 50, null: true
      String :objective, size: 2000, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_operaton_activities_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:operaton_activities) do
      primary_key :id
      String :external_activity_id, null: false
      String :external_process_id
      String :process_definition_key
      String :activity_id
      String :activity_name
      String :activity_type
      String :task_id
      String :assignee
      DateTime :start_time
      DateTime :end_time
      Integer :duration_in_millis
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_okrs_history_table(db)
    db.create_table(:okrs_history) do
      primary_key :id
      foreign_key :okr_id, :okrs, type: :uuid
      String :external_okr_id, size: 255, null: false
      String :code, size: 20, null: true
      String :status, size: 50, null: true
      String :objective, size: 2000, null: true
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  def create_krs_table(db)
    db.create_table(:krs) do
      primary_key :id
      String :external_kr_id, size: 255, null: false
      foreign_key :okr_id, :okrs, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 2000, null: true
      String :status, size: 50, null: true
      String :code, size: 20, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_operaton_incidents_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:operaton_incidents) do
      primary_key :id
      String :external_incident_id, null: false
      String :external_process_id
      String :process_definition_key
      String :activity_id
      String :incident_type
      String :incident_message
      TrueClass :resolved
      DateTime :create_time
      DateTime :end_time
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_krs_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:krs_history) do
      primary_key :id
      foreign_key :kr_id, :krs, type: :uuid
      String :external_kr_id, size: 255, null: false
      foreign_key :okr_id, :okrs, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 2000, null: true
      String :status, size: 50, null: true
      String :code, size: 20, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_organizational_units_table(db)
    db.create_table(:organizational_units) do
      primary_key :id
      String :external_org_unit_id, size: 255, null: false
      String :name, size: 255, null: false
      String :status
      String :external_id
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_organizational_units_history_table(db)
    db.create_table(:organizational_units_history) do
      primary_key :id
      String :external_org_unit_id, size: 255, null: false
      foreign_key :organizational_unit_id, :organizational_units, type: :uuid
      String :name, size: 255, null: false
      String :status
      String :external_id
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_apex_processes_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:processes) do
      primary_key :id
      String :external_process_id, size: 255, null: false
      foreign_key :org_unit_id, :organizational_units, type: :uuid
      String :name, size: 255, null: false
      String :description, size: 2000, null: true
      Date :start_date, null: true
      Date :end_date, null: true
      Date :deadline, null: true
      String :status
      String :external_id
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_apex_processes_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:processes_history) do
      primary_key :id
      foreign_key :process_id, :processes, type: :uuid
      String :external_process_id, size: 255, null: false
      foreign_key :org_unit_id, :organizational_units, type: :uuid
      String :name, size: 255, null: false
      String :description, size: 2000, null: true
      Date :start_date, null: true
      Date :end_date, null: true
      Date :deadline, null: true
      String :status
      String :external_id
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_apex_milestones_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:apex_milestones) do
      primary_key :id
      String :external_apex_milestone_id, size: 255, null: false
      foreign_key :kr_id, :krs, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 2000, null: false
      Integer :milestone_order, null: false
      Float :percentage, null: true
      Date :completion_date, null: true
      Boolean :is_completed, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  def create_apex_milestones_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:apex_milestones_history) do
      primary_key :id
      foreign_key :apex_milestone_id, :apex_milestones, type: :uuid
      String :external_apex_milestone_id, size: 255, null: false
      foreign_key :kr_id, :krs, null: false, on_delete: :cascade, type: :uuid
      String :description, size: 2000, null: false
      Integer :milestone_order, null: false
      Float :percentage, null: true
      Date :completion_date, null: true
      Boolean :is_completed, default: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end

  def create_tasks_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:tasks) do
      primary_key :id
      String :external_task_id, size: 255, null: false
      foreign_key :process_id, :processes, null: true, on_delete: :cascade, type: :uuid
      foreign_key :milestone_id, :apex_milestones, null: true, on_delete: :cascade, type: :uuid
      String :name, size: 255, null: false
      String :description, size: 2000, null: true
      String :assigned_to, size: 255, null: true
      String :status, size: 50, null: true
      Date :start_date, null: true
      Date :end_date, null: true
      Date :deadline, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_tasks_history_table(db) # rubocop:disable Metrics/MethodLength
    db.create_table(:tasks_history) do
      primary_key :id
      foreign_key :task_id, :tasks, type: :uuid
      String :external_task_id, size: 255, null: false
      foreign_key :process_id, :processes, null: true, on_delete: :cascade, type: :uuid
      foreign_key :milestone_id, :apex_milestones, null: true, on_delete: :cascade, type: :uuid
      String :name, size: 255, null: false
      String :description, size: 2000, null: true
      String :assigned_to, size: 255, null: true
      String :status, size: 50, null: true
      Date :start_date, null: true
      Date :end_date, null: true
      Date :deadline, null: true
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_weekly_scope_tasks_table(db)
    db.create_table(:weekly_scope_tasks) do
      primary_key :id
      String :external_weekly_scope_task_id, size: 255, null: false
      foreign_key :task_id, :tasks, null: false, on_delete: :cascade, type: :uuid
      foreign_key :weekly_scope_id, :weekly_scopes, null: false, on_delete: :cascade, type: :uuid
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end

  def create_weekly_scope_tasks_history_table(db)
    db.create_table(:weekly_scope_tasks_history) do
      primary_key :id
      foreign_key :weekly_scope_task_id, :weekly_scope_tasks, type: :uuid
      String :external_weekly_scope_task_id, size: 255, null: false
      foreign_key :task_id, :tasks, null: false, on_delete: :cascade, type: :uuid
      foreign_key :weekly_scope_id, :weekly_scopes, null: false, on_delete: :cascade, type: :uuid
      DateTime :created_at, default: Sequel.lit('CURRENT_TIMESTAMP')
      DateTime :updated_at, default: Sequel.lit('CURRENT_TIMESTAMP')
    end
  end
end
