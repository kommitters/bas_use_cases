# frozen_string_literal: true

require_relative '../lib/execution/orchestrator'

##
# Main entry point for the orchestrator.
# It will run the orchestrator and start
# the execution of the scheduled scripts.
# The schedules are defined in the UseCasesExecution::Schedules module.

orchestrator = Whatsapp::Execution::Orchestrator.new
orchestrator.run
