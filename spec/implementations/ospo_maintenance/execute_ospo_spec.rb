# frozen_string_literal: true

require 'rspec'
require_relative '../../../src/use_cases_execution/ospo_maintenance/execute_ospo'

RSpec.describe 'OSPOMaintenance::ExecuteOSPO' do
  describe '#run_task' do
    task = { path: File.expand_path(
      '../../../src/use_cases_execution/ospo_maintenance/projects/ospo_maintenance_tests.rb', __dir__
    ) }
    before do
      # Stub TASKS to include only the test task
      stub_const('TASKS', [task])

      # Mock system calls to avoid actual execution
      allow(Kernel).to receive(:system).and_return(true)
    end

    it 'prints a message indicating the task is running' do
      expect do
        run_task(task)
      end.to output(/Running task: .*ospo_maintenance_tests.rb/).to_stdout
    end

    it 'handles timeouts gracefully' do
      allow(Timeout).to receive(:timeout).and_raise(Timeout::Error)

      expect do
        run_task(task)
      end.to output(/Task .*ospo_maintenance_tests.rb was stopped after 5 minutes./).to_stdout
    end
  end
end
