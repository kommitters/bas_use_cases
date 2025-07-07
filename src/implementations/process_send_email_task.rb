# frozen_string_literal: true

require 'time'
require '../bas/lib/bas/bot/base'

module Implementation
  ##
  # The Implementation::ProcessSendEmailTask class serves as a worker bot.
  # It reads a polled 'send_email' task from the shared storage, executes
  # the business logic, and stores the result back into the shared storage
  # for the completion bot.
  #
  class ProcessSendEmailTask < Bas::Bot::Base
    # Process function to execute the business logic for a 'send_email' task.
    #
    def process
      # The bot framework provides the unprocessed record in `read_response.data`
      task_data = read_response.data

      unless task_data && task_data['topic_name'] == 'send_email'
        return { success: { message: "Ignoring task with topic: #{task_data&.[]('topic_name')}" } }
      end

      puts "--> [Worker] Procesando tarea: #{task_data['task_id']} (Topic: #{task_data['topic_name']})"

      # --- Business Logic Simulation ---
      result_payload = {
        message: "Email sent successfully at #{Time.now.utc.iso8601}",
        recipient: task_data.dig('task_data', 'variables', 'recipient', 'value') || 'unknown',
        status_code: 200
      }

      puts "--> [Worker] Lógica de negocio completada. Resultado: #{result_payload.inspect}"

      # The returned payload will be stored for the next bot in the chain.
      # We pass along the original task data so the completer knows which task to complete.
      { success: { original_task_data: task_data, result_variables: result_payload } }
    rescue StandardError => e
      puts "--> [Worker] ERROR: #{e.message}"
      { error: { message: e.message, backtrace: e.backtrace } }
    end
  end
end
