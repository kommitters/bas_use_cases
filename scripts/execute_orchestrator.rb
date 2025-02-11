# frozen_string_literal: true

# !/usr/bin/env ruby

require 'bundler/setup'
require 'bas/orchestrator'
require_relative '../src/use_cases_execution/schedules'

# # ##
# # # Main entry point for the orchestrator.
# # # It will run the orchestrator and start
# # # the execution of the scheduled scripts.
# # # The schedules are defined in the UseCasesExecution::Schedules module.

schedules = UseCasesExecution::Schedules.load
orchestrator = Bas::Orchestrator::Manager.new(schedules)
orchestrator.run
