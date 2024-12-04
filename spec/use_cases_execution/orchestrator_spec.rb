# frozen_string_literal: true

require 'rspec'
require 'fileutils'
require_relative '../../src/use_cases_execution/orchestrator'

RSpec.describe ScheduleOrchestrator::Orchestrator do
  let(:schedules) do
    [
      { path: '/websites_availability/fetch_domain_services_from_notion.rb', interval: 600_000 },
      { path: '/websites_availability/notify_domain_availability.rb', interval: 60_000 },
      { path: '/websites_availability/garbage_collector.rb', time: ['00:00:00'] },
      { path: '/pto_next_week/fetch_next_week_pto_from_notion.rb', time: ['12:40:00'], day: ['Monday'] },
      { path: '/pto/fetch_pto_from_notion.rb', time: ['13:10:00'] }
    ]
  end

  before do
    allow(UseCasesExecution::Schedules).to receive(:schedules).and_return(schedules)
    allow_any_instance_of(Object).to receive(:system).and_return(true)
  end

  describe '#run' do
    it 'executes scripts with intervals' do
      allow(Time).to receive(:new).and_return(Time.local(2024, 12, 2, 12, 40, 0))

      orchestrator = ScheduleOrchestrator::Orchestrator.new

      schedules.each do |script|
        if script[:interval]
          orchestrator.instance_variable_get(:@last_executions)[script[:path]] = 0
          expect_any_instance_of(Object).to receive(:system).with(a_string_including(script[:path]))
        end
      end

      allow(orchestrator).to receive(:loop).and_yield
      orchestrator.run
    end

    it 'executes scripts at a specific time' do
      allow(Time).to receive(:new).and_return(Time.local(2024, 12, 2, 0, 0, 0))

      orchestrator = ScheduleOrchestrator::Orchestrator.new

      expect_any_instance_of(Object).to receive(:system).with(
        a_string_including('/websites_availability/garbage_collector.rb')
      )

      allow(orchestrator).to receive(:loop).and_yield
      orchestrator.run
    end

    it 'executes scripts with specific time and day' do
      allow(Time).to receive(:new).and_return(Time.local(2024, 12, 2, 12, 40, 0))

      orchestrator = ScheduleOrchestrator::Orchestrator.new

      expect_any_instance_of(Object).to receive(:system).with(
        a_string_including('/pto_next_week/fetch_next_week_pto_from_notion.rb')
      )

      allow(orchestrator).to receive(:loop).and_yield
      orchestrator.run
    end
  end
end
