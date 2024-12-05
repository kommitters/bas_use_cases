# frozen_string_literal: true

require 'rspec'
require_relative '../../src/use_cases_execution/schedules'

RSpec.describe UseCasesExecution::Schedules do
  describe '.schedules' do
    it 'loads only the provided schedules' do
      birthday_schedule = [
        { path: '/birthday/fetch_birthday_from_notion.rb', time: ['01:00:00'] },
        { path: '/birthday/format_birthday.rb', time: ['01:10:00'] },
        { path: '/birthday/garbage_collector.rb', time: ['13:00:00'] },
        { path: '/birthday/notify_birthday_in_discord.rb', time: ['13:10:00'] }
      ]

      birthday_next_week_schedule = [
        { path: '/birthday_next_week/fetch_next_week_birthday_from_notion.rb', time: ['01:00:00'] },
        { path: '/birthday_next_week/format_next_week_birthday.rb', time: ['01:10:00'] },
        { path: '/birthday_next_week/garbage_collector.rb', time: ['13:00:00'] },
        { path: '/birthday_next_week/notify_next_week_birthday_in_discord.rb', time: ['13:10:00'] }
      ]

      stub_const('UseCasesExecution::Schedules::BIRTHDAY_SCHEDULES', birthday_schedule)
      stub_const('UseCasesExecution::Schedules::BIRTHDAY_NEXT_WEEK_SCHEDULES', birthday_next_week_schedule)

      allow(UseCasesExecution::Schedules).to receive(:constants)
        .and_return(%i[BIRTHDAY_SCHEDULES BIRTHDAY_NEXT_WEEK_SCHEDULES])

      expect(UseCasesExecution::Schedules.schedules).to eq(birthday_schedule + birthday_next_week_schedule)
    end
  end
end
