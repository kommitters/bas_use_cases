# frozen_string_literal: true

require 'time'
require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::ProcessSendEmailTask class serves as a worker bot.
  # It reads a polled 'send_email' task from the shared storage, executes
  # the business logic, and stores the result back into the shared storage
  # for the completion bot.
  #
  # Example
  #  options = {}
  #
  #  read_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'operaton_tasks',
  #   tag: 'OperatonTaskPolled'
  #  }
  #
  #  write_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'operaton_tasks',
  #   tag: 'OperatonTaskProcessed_SendEmail'
  # }
  #
  # begin
  #  # The bot reads a 'Polled' task and writes a 'Processed' task.
  #  # The base bot logic handles marking the read record as 'processed'.
  #  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::ProcessSendEmailTask.new(options, shared_storage).execute
  # rescue StandardError => e
  #  Logger.new($stdout).info(e.message)
  # end
  class ProcessSendEmailTask < Bas::Bot::Base
    # Process function to execute the business logic for a 'send_email' task.
    #
    def process
      task_data = read_response.data

      validation_result = validate_task_data(task_data)
      return validation_result if validation_result

      puts "--> [Worker] Processing task: #{task_data['task_id']} (Topic: #{task_data['topic_name']})"

      result_payload = execute_email_sending_logic(task_data)

      puts "--> [Worker] Business logic completed. Result: #{result_payload.inspect}"

      { success: { original_task_data: task_data, result_variables: result_payload } }
    rescue StandardError => e
      handle_error(e)
    end

    private

    def validate_task_data(task_data)
      return if task_data && task_data['topic_name'] == 'send_email'

      { success: { message: "Ignoring task with topic: #{task_data&.[]('topic_name')}" } }
    end

    def execute_email_sending_logic(task_data)
      { message: "Email sent successfully at #{Time.now.utc.iso8601}",
        recipient: task_data.dig('task_data', 'variables', 'recipient', 'value') || 'unknown',
        status_code: 200 }
    end

    def handle_error(error)
      puts "--> [Worker] ERROR: #{error.message}"
      { error: { message: error.message, backtrace: error.backtrace } }
    end
  end
end
