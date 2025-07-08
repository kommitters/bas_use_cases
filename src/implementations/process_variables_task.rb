# frozen_string_literal: true

require 'time'
require 'bas/bot/base'
require 'logger'

module Implementation
  ##
  # The Implementation::ProcessVariablesTask class serves as a worker bot.
  # It reads a polled 'variables' task from the shared storage, executes
  # the business logic, and stores the result back for the completion bot.
  #
  # Example
  #  options = {}
  #
  # # This bot reads a 'Polled' task.
  #  read_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'operaton_tasks',
  #   tag: 'OperatonTaskPolled'
  # }
  #
  # It writes a 'Processed_Variables' task after executing its logic.
  # write_options = {
  #  connection: Config::CONNECTION,
  #  db_table: 'operaton_tasks',
  #  tag: 'OperatonTaskProcessed_Variables'
  # }
  #
  # begin
  #  # The bot reads a 'Polled' task and writes a 'Processed_Variables' task.
  #  # The base bot logic handles marking the read record as 'processed'.
  #  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::ProcessVariablesTask.new(options, shared_storage).execute
  # rescue StandardError => e
  #  Logger.new($stdout).info(e.message)
  # end
  class ProcessVariablesTask < Bas::Bot::Base
    # Process function to execute the business logic for a 'variables' task.
    #
    def process
      task_data = read_response.data

      validation_result = validate_task_data(task_data)
      return validation_result if validation_result

      Logger.new($stdout).info("[Worker] Processing task: #{task_data['task_id']} (Topic: #{task_data['topic_name']})")

      result_payload = execute_business_logic(task_data)

      Logger.new($stdout).info("--> [Worker] Business logic completed. Result: #{result_payload.inspect}")

      { success: { original_task_data: task_data, result_variables: result_payload } }
    rescue StandardError => e
      handle_error(e)
    end

    private

    def validate_task_data(task_data)
      return if task_data && task_data['topic_name'] == 'variables'

      { success: { message: "Ignoring task with topic: #{task_data&.[]('topic_name')}" } }
    end

    def execute_business_logic(task_data)
      input_variables = task_data.dig('task_data', 'variables') || {}
      { "variablesProcessed": input_variables.keys.length }
    end

    def handle_error(error)
      puts "--> [Worker] ERROR: #{error.message}"
      { error: { message: error.message, backtrace: error.backtrace } }
    end
  end
end
