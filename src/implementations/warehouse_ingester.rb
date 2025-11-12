# frozen_string_literal: true

require 'bas/bot/base'
require_relative '../../log/bas_logger'
require_relative '../utils/warehouse/service_registry'

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
    # Pulls in the central mapping of entity types to their service classes.
    SERVICES = Utils::Warehouse::ServiceRegistry::SERVICES

    ##
    # The main entry point for the bot.
    # It validates the incoming data, configures the correct service,
    # processes the items, and logs the outcome.
    #
    def process
      return { success: { processed: 0 } } unless ingestion_ready?

      config = SERVICES[@type]
      @external_key = config[:external_key]
      @service = config[:service].new(process_options[:db])

      result = process_items

      if result[:success]
        count = result.dig(:success, :processed)
        log_ingestion_event(:info, "Ingestion complete. Processed #{count} items.", processed: count)
      end

      result
    end

    private

    ##
    # Iterates over all records from the `read_response` and
    # attempts to upsert each one.
    #
    def process_items
      processed = 0
      read_response.data['content'].each do |item|
        processed += 1 if upsert(item)
      end

      { success: { processed: processed } }
    rescue StandardError => e
      log_ingestion_event(:error, 'Ingestion failed during upsert', error: e)
      { error: { message: e.message, type: @type } }
    end

    ##
    # Performs an "upsert" (update or insert) for a single item.
    # It finds the item by its external ID. If it exists, it updates it.
    # If not, it inserts it.
    #
    def upsert(item)
      external_id = item[@external_key]
      return false unless external_id

      found = @service.query({ @external_key.to_sym => external_id }).first

      if found
        @service.update(found[:id], item)
      else
        @service.insert(item)
      end

      true
    end

    ##
    # Centralized logging helper.
    # Formats and sends a structured log message to the `BAS_LOGGER`.
    #
    def log_ingestion_event(level, message, processed: nil, error: nil)
      payload = {
        invoker: 'WarehouseIngester',
        message: message,
        context: { action: 'ingest', entity_type: @type }
      }

      payload[:context][:processed] = processed unless processed.nil?

      payload.merge!(format_error_payload(error, message)) if error

      BAS_LOGGER.send(level, payload)
    end

    ##
    # Guard clause method to check if ingestion should proceed.
    # It validates the `read_response` and ensures a serviceable
    # entity type (`@type`) is set.
    #
    def ingestion_ready?
      if unprocessable_response
        log_ingestion_event(:info, 'Ingestion skipped: unprocessable response.', processed: 0)
        return false
      end

      @type = read_response.data['type']
      unless @type && SERVICES[@type]
        log_ingestion_event(:warn, "Ingestion skipped: type '#{@type}' not serviceable.", processed: 0)
        return false
      end

      true
    end

    ##
    # Builds the error-specific part of the log payload.
    #
    def format_error_payload(error, original_message)
      {
        message: "#{original_message}: #{error.message}",
        error_class: error.class.to_s,
        backtrace: error.backtrace.first(5)
      }
    end
  end
end
