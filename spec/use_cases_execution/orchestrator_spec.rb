# frozen_string_literal: true

require 'rspec'
require 'fileutils'
require_relative '../../src/use_cases_execution/orchestrator'

RSpec.describe OrchestratorWithSchedules::Orchestrator do
  let(:schedules) do
    [
      { path: '/websites_availability/fetch_domain_services_from_notion.rb', interval: 600_000 },
      { path: '/websites_availability/notify_domain_availability.rb', interval: 60_000 },
      { path: '/websites_availability/garbage_collector.rb', time: ['00:00:00'] },
      { path: '/pto_next_week/fetch_next_week_pto_from_notion.rb', time: ['12:40:00'], day: ['Monday'] },
      { path: '/pto/fetch_pto_from_notion.rb', time: ['13:10:00'] }
    ]
  end

  let(:base_path) { File.join(__dir__, 'mock_scripts') }

  before do
    allow_any_instance_of(Object).to receive(:system).and_return(true)

    FileUtils.mkdir_p(base_path) unless Dir.exist?(base_path)

    OrchestratorWithSchedules::Paths::SCHEDULES.clear
    OrchestratorWithSchedules::Paths::SCHEDULES.concat(schedules)
  end

  after do
    FileUtils.rm_rf(base_path)
  end

  describe '#run' do
    it 'executes scripts with intervals' do
      allow(Time).to receive(:new).and_return(Time.local(2024, 12, 2, 12, 40, 0))

      orchestrator = OrchestratorWithSchedules::Orchestrator.new(base_path)

      schedules.each do |script|
        if script[:interval]
          orchestrator.instance_variable_get(:@last_executions)[script[:path]] = 0
          expect_any_instance_of(Object).to receive(:system).with("ruby #{File.join(base_path, script[:path])}")
        end
      end

      allow(orchestrator).to receive(:loop).and_yield
      orchestrator.run
    end

    it 'executes scripts at a specific time' do
      allow(Time).to receive(:new).and_return(Time.local(2024, 12, 2, 0, 0, 0))

      orchestrator = OrchestratorWithSchedules::Orchestrator.new(base_path)

      expect_any_instance_of(Object).to receive(:system).with(
        "ruby #{File.join(base_path, '/websites_availability/garbage_collector.rb')}"
      )

      allow(orchestrator).to receive(:loop).and_yield
      orchestrator.run
    end

    it 'executes scripts with specific time and day' do
      allow(Time).to receive(:new).and_return(Time.local(2024, 12, 2, 12, 40, 0))

      orchestrator = OrchestratorWithSchedules::Orchestrator.new(base_path)

      expect_any_instance_of(Object).to receive(:system).with(
        "ruby #{File.join(base_path, '/pto_next_week/fetch_next_week_pto_from_notion.rb')}"
      )

      allow(orchestrator).to receive(:loop).and_yield
      orchestrator.run
    end
  end
end
