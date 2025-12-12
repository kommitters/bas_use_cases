# frozen_string_literal: true

require_relative '../../services/postgres/activity'
require_relative '../../services/postgres/document'
require_relative '../../services/postgres/document_activity_log'
require_relative '../../services/postgres/apex_people'
require_relative '../../services/postgres/work_log'
require_relative '../../services/postgres/github_release'
require_relative '../../services/postgres/github_issue'
require_relative '../../services/postgres/github_pull_request'
require_relative '../../services/postgres/github_repository'
require_relative '../../services/postgres/kpi'
require_relative '../../services/postgres/calendar_event'
require_relative '../../services/postgres/operaton_process'
require_relative '../../services/postgres/operaton_activity'
require_relative '../../services/postgres/operaton_incident'
require_relative '../../services/postgres/okr'
require_relative '../../services/postgres/kr'
require_relative '../../services/postgres/apex_milestone'
require_relative '../../services/postgres/organizational_unit'
require_relative '../../services/postgres/apex_process'
require_relative '../../services/postgres/task'
require_relative '../../services/postgres/weekly_scope'
require_relative '../../services/postgres/weekly_scope_task'

module Utils
  module Warehouse
    ##
    # The `ServiceRegistry` module acts as a central configuration point
    # for the `WarehouseIngester`. It maps entity type strings to their
    # corresponding database service class and the external key
    # used for upsert operations.
    #
    module ServiceRegistry
      ##
      # Central lookup hash mapping an entity type string (as received from
      # the warehouse_sync table) to its corresponding service configuration.
      #
      SERVICES = {
        'document' => { service: Services::Postgres::Document, external_key: 'external_document_id' },
        'document_activity_log' => {
          service: Services::Postgres::DocumentActivityLog, external_key: 'unique_identifier'
        },
        'people' => { service: Services::Postgres::ApexPeople, external_key: 'external_person_id' },
        'operaton_process' => { service: Services::Postgres::OperatonProcess, external_key: 'external_process_id' },
        'operaton_activity' => { service: Services::Postgres::OperatonActivity, external_key: 'external_activity_id' },
        'operaton_incident' => { service: Services::Postgres::OperatonIncident, external_key: 'external_incident_id' },
        'work_log' => { service: Services::Postgres::WorkLog, external_key: 'external_work_log_id' },
        'github_release' => { service: Services::Postgres::GithubRelease, external_key: 'external_github_release_id' },
        'github_issue' => { service: Services::Postgres::GithubIssue, external_key: 'external_github_issue_id' },
        'github_pull_request' => { service: Services::Postgres::GithubPullRequest,
                                   external_key: 'external_github_pull_request_id' },
        'github_repository' => { service: Services::Postgres::GithubRepository,
                                 external_key: 'external_repository_id' },
        'kpi' => { service: Services::Postgres::Kpi, external_key: 'external_kpi_id' },
        'calendar_event' => { service: Services::Postgres::CalendarEvent, external_key: 'external_calendar_event_id' },
        'okr' => { service: Services::Postgres::Okr, external_key: 'external_okr_id' },
        'kr' => { service: Services::Postgres::Kr, external_key: 'external_kr_id' },
        'apex_milestone' => { service: Services::Postgres::ApexMilestone, external_key: 'external_apex_milestone_id' },
        'organizational_unit' => { service: Services::Postgres::OrganizationalUnit,
                                   external_key: 'external_org_unit_id' },
        'process' => { service: Services::Postgres::ApexProcess, external_key: 'external_process_id' },
        'task' => { service: Services::Postgres::Task, external_key: 'external_task_id' },
        'weekly_scope' => { service: Services::Postgres::WeeklyScope, external_key: 'external_weekly_scope_id' },
        'weekly_scope_task' => { service: Services::Postgres::WeeklyScopeTask, external_key: 'external_weekly_scope_task_id' }
      }.freeze
    end
  end
end
