# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../../log/bas_logger'
require_relative '../services/postgres/activity'
require_relative '../services/postgres/document'
require_relative '../services/postgres/document_activity_log'
require_relative '../services/postgres/domain'
require_relative '../services/postgres/key_result'
require_relative '../services/postgres/milestone'
require_relative '../services/postgres/person'
require_relative '../services/postgres/project'
require_relative '../services/postgres/work_item'
require_relative '../services/postgres/work_log'
require_relative '../services/postgres/github_release'
require_relative '../services/postgres/github_issue'
require_relative '../services/postgres/github_pull_request'
require_relative '../services/postgres/kpi'
require_relative '../services/postgres/calendar_event'
require_relative '../services/postgres/operaton_process'
require_relative '../services/postgres/operaton_activity'
require_relative '../services/postgres/operaton_incident'
require_relative '../services/postgres/okr'
require_relative '../services/postgres/kr'
require_relative '../services/postgres/apex_milestone'
require_relative '../services/postgres/organizational_unit'
require_relative '../services/postgres/apex_process'
require_relative '../services/postgres/task'
require_relative '../services/postgres/weekly_scope'
require_relative '../services/postgres/weekly_scope_task'

module Implementation
  ##
  # The Implementation::WarehouseIngester class is a bot that reads records from
  # shared Postgres storage and uses the appropriate Postgres service to insert or update
  # records based on their type.
  #
  # It supports dynamic entity types such as `project`, `activity`, `work_item`, `domain`, and `person`,
  # using corresponding services to perform the necessary database operations.
  #
  # <br>
  # <b>Example</b>
  #
  # array = PG::TextEncoder::Array.new.encode(
  #   %w[FetchWorkItemsFromNotionDatabase FetchProjectsFromNotionDatabase FetchActivitiesFromNotionDatabase]
  # )

  # read_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'warehouse_sync',
  #   where: 'archived=$1 AND tag=ANY($2) AND stage=$3 ORDER BY inserted_at DESC',
  #   params: [false, array, 'unprocessed']
  # }

  # write_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'warehouse_sync',
  #   tag: 'WarehouseSyncProcessed'
  # }

  # options = {
  #   db: Config::CONNECTION
  # }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::WarehouseIngester.new(options, shared_storage).execute
  #
  class WarehouseIngester < Bas::Bot::Base
    SERVICES = {
      'document' => { service: Services::Postgres::Document, external_key: 'external_document_id' },
      'document_activity_log' => {
        service: Services::Postgres::DocumentActivityLog, external_key: 'unique_identifier'
      },
      'person' => { service: Services::Postgres::Person, external_key: 'external_person_id' },
      'operaton_process' => { service: Services::Postgres::OperatonProcess, external_key: 'external_process_id' },
      'operaton_activity' => { service: Services::Postgres::OperatonActivity, external_key: 'external_activity_id' },
      'operaton_incident' => { service: Services::Postgres::OperatonIncident, external_key: 'external_incident_id' },
      'work_log' => { service: Services::Postgres::WorkLog, external_key: 'external_work_log_id' },
      'github_release' => { service: Services::Postgres::GithubRelease, external_key: 'external_github_release_id' },
      'github_issue' => { service: Services::Postgres::GithubIssue, external_key: 'external_github_issue_id' },
      'github_pull_request' => { service: Services::Postgres::GithubPullRequest,
                                 external_key: 'external_github_pull_request_id' },
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

    def process
      return { success: { processed: 0 } } unless setup_ingestion_valid

      config = SERVICES[@type]
      @external_key = config[:external_key]
      @service = config[:service].new(process_options[:db])

      result = process_items

      if result[:success]
        count = result.dig(:success, :processed)
        log_ingestion(:info, "Ingestion complete. Processed #{count} items.", processed: count)
      end

      result
    end

    private

    def process_items
      processed = 0
      read_response.data['content'].each do |item|
        upsert(item)
        processed += 1
      end

      { success: { processed: processed } }
    rescue StandardError => e
      log_ingestion(:error, 'Ingestion failed during upsert', error: e)
      { error: { message: e.message, type: @type } }
    end

    def upsert(item)
      external_id = item[@external_key]
      return unless external_id

      found = @service.query({ @external_key.to_sym => external_id }).first

      if found
        @service.update(found[:id], item)
      else
        @service.insert(item)
      end
    end

    def log_ingestion(level, message, processed: nil, error: nil)
      payload = {
        invoker: 'WarehouseIngester',
        message: message,
        context: { action: 'ingest', entity_type: @type }
      }

      payload[:context][:processed] = processed unless processed.nil?

      payload[:message] = "#{message}: #{error.message}" if error

      BAS_LOGGER.send(level, payload)
    end

    def setup_ingestion_valid
      if unprocessable_response
        log_ingestion(:info, 'Ingestion skipped: unprocessable response.', processed: 0)
        return false
      end

      @type = read_response.data['type']
      unless @type && SERVICES[@type]
        log_ingestion(:warn, "Ingestion skipped: type '#{@type}' not serviceable.", processed: 0)
        return false
      end

      true
    end
  end
end
