# frozen_string_literal: true

require 'time'
require '../bas/lib/bas/bot/base'

module Implementation
  ##
  # The Implementation::ProcessVariablesTask class serves as a worker bot.
  # It reads a polled 'variables' task from the shared storage, executes
  # the business logic, and stores the result back for the completion bot.
  #
  class ProcessVariablesTask < Bas::Bot::Base
    # Process function to execute the business logic for a 'variables' task.
    #
    def process
      # The bot framework provides the unprocessed record in `read_response.data`
      task_data = read_response.data

      # This worker only cares about tasks with the 'variables' topic.
      unless task_data && task_data['topic_name'] == 'variables'
        return { success: { message: "Ignoring task with topic: #{task_data&.[]('topic_name')}" } }
      end

      puts "--> [Worker] Procesando tarea: #{task_data['task_id']} (Topic: #{task_data['topic_name']})"

      # --- Business Logic Simulation ---
      # Here, we would process the variables from the task.
      # For this example, we'll just count them and return the result as a process variable.
      input_variables = task_data.dig('task_data', 'variables') || {}
      
      result_payload = {
        "variablesProcessed": input_variables.keys.length
      }

      puts "--> [Worker] Lógica de negocio completada. Resultado: #{result_payload.inspect}"

      # The returned payload will be stored for the next bot in the chain.
      { success: { original_task_data: task_data, result_variables: result_payload } }
    rescue StandardError => e
      puts "--> [Worker] ERROR: #{e.message}"
      { error: { message: e.message, backtrace: e.backtrace } }
    end
  end
end
