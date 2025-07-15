# frozen_string_literal: true

require 'time'
require 'bas/bot/base'
require 'bas/utils/operaton/external_task_client'
require 'logger'

module Implementation
  ##
  # The Implementation::CompleteOperatonTask class is the final bot in the chain.
  # It reads a processed task from the shared storage and calls the Operaton API
  # to complete the external service task, effectively closing the loop.
  #
  #
  # Example
  #  options = {
  #   operaton_base_url: ENV.fetch('OPERATON_BASE_URL', 'http://localhost:8080/engine-rest'),
  #   worker_id: ENV.fetch('OPERATON_POLLER_WORKER_ID', "operaton_completer_#{Time.now.to_i}")
  #   }
  #
  ## This bot reads records created by ANY worker.
  #  read_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'operaton_tasks',
  #   We use a LIKE query to find any processed task, regardless of the topic.
  #   where: 'archived=$1 AND tag LIKE $2 AND stage=$3 ORDER BY inserted_at ASC',
  #   params: [false, 'OperatonTaskProcessed_%', 'unprocessed']
  # }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'operaton_tasks',
  #     tag: 'OperatonTaskCompleted'
  #   }
  #
  #   begin
  #     shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #     Implementation::CompleteOperatonTask.new(options, shared_storage).execute
  #   rescue StandardError => e
  #     Logger.new($stdout).info(e.message)
  #   end
  class CompleteOperatonTask < Bas::Bot::Base
    # Process function to complete the task in Operaton.
    #
    def process
      task_variables = retrieve_and_validate_task_info
      return task_variables[:error_or_success_response] if task_variables[:error_or_success_response]

      execute_completion_flow(task_variables)
    rescue StandardError => e
      handle_error(e)
    end

    private

    def retrieve_and_validate_task_info
      processed_data = read_response.data
      original_task = processed_data['original_task_data']
      result_vars = processed_data['result_variables']

      unless original_task && result_vars
        return { error_or_success_response: { success: { message: 'Ignoring malformed record.' } } }
      end

      original_task_data = original_task['task_data']
      worker_id = original_task_data['workerId']

      { original_task: original_task, result_vars: result_vars,
        original_task_data: original_task_data, worker_id: worker_id }
    end

    def execute_completion_flow(task_variables)
      log_task_completion(task_variables[:original_task_data], task_variables[:worker_id])

      client = initialize_operaton_client(@process_options[:operaton_base_url], @process_options[:worker_id])
      complete_operaton_task(client, task_variables[:original_task_data]['id'], task_variables[:result_vars])

      Logger.new($stdout).info('--> [Completer] Task successfully completed in Operaton.')

      build_success_response(task_variables[:original_task], read_response)
    end

    def log_task_completion(original_task_data, worker_id)
      Logger.new($stdout).info("--> [Completer] Finalizing task: #{original_task_data['id']} " \
           "with Topic: #{original_task_data['topicName']} " \
           "using workerId: #{worker_id}")
    end

    def initialize_operaton_client(base_url, worker_id)
      Utils::Operaton::ExternalTaskClient.new(
        base_url: base_url,
        worker_id: worker_id
      )
    end

    def complete_operaton_task(client, task_id, result_vars)
      client.complete(task_id, result_vars)
    end

    def build_success_response(original_task, read_response)
      { success: { completed_task_id: original_task['task_id'], completed_at: Time.now.utc.iso8601,
                   original_record_id: read_response.id } }
    end

    def handle_error(error)
      puts "--> [Completer] ERROR: #{error.message}"
      { error: { message: error.message, backtrace: error.backtrace } }
    end
  end
end
