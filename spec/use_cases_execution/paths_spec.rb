# frozen_string_literal: true

require 'rspec'
require 'sorted_set'
require_relative '../../src/use_cases_execution/orchestrator'

RSpec.describe OrchestratorWithSchedules::Paths do
  before do
    # create modules with SCHEDULE constants
    stub_const('BirthdayConfig', Module.new)
    stub_const('BirthdayConfig::SCHEDULE', [
                 { path: '/birthday/fetch_birthday_from_notion.rb', time: ['01:00:00'], module: :BirthdayConfig },
                 { path: '/birthday/format_birthday.rb', time: ['01:10:00'], module: :BirthdayConfig },
                 { path: '/birthday/garbage_collector.rb', time: ['13:00:00'], module: :BirthdayConfig },
                 { path: '/birthday/notify_birthday_in_discord.rb', time: ['13:10:00'], module: :BirthdayConfig }
               ])

    stub_const('BirthdayNextWeekConfig', Module.new)
    stub_const('BirthdayNextWeekConfig::SCHEDULE', [
                 { path: '/birthday_next_week/fetch_next_week_birthday_from_notion.rb', time: ['01:00:00'],
                   module: :BirthdayNextWeekConfig },
                 { path: '/birthday_next_week/format_next_week_birthday.rb', time: ['01:10:00'],
                   module: :BirthdayNextWeekConfig },
                 { path: '/birthday_next_week/garbage_collector.rb', time: ['13:00:00'],
                   module: :BirthdayNextWeekConfig },
                 { path: '/birthday_next_week/notify_next_week_birthday_in_discord.rb', time: ['13:10:00'],
                   module: :BirthdayNextWeekConfig }
               ])

    stub_const('DigitalOceanBillAlertConfig', Module.new)
    stub_const('DigitalOceanBillAlertConfig::SCHEDULE', [
                 { path: '/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb', interval: 300_000,
                   module: :DigitalOceanBillAlertConfig },
                 { path: '/digital_ocean_bill_alert/format_do_bill_alert.rb', interval: 300_000,
                   module: :DigitalOceanBillAlertConfig },
                 { path: '/digital_ocean_bill_alert/garbage_collector.rb', interval: 300_000,
                   module: :DigitalOceanBillAlertConfig },
                 { path: '/digital_ocean_bill_alert/notify_do_bill_alert_discord.rb', interval: 300_000,
                   module: :DigitalOceanBillAlertConfig }
               ])

    stub_const('OspoMaintenanceConfig', Module.new)
    stub_const('OspoMaintenanceConfig::SCHEDULE', [
                 { path: '/ospo_maintenance/create_work_item.rb', interval: 600_000, module: :OspoMaintenanceConfig },
                 { path: '/ospo_maintenance/update_work_item.rb', interval: 600_000, module: :OspoMaintenanceConfig },
                 { path: '/ospo_maintenance/verify_issue_existance_in_notion.rb', interval: 600_000,
                   module: :OspoMaintenanceConfig }
               ])

    stub_const('PtoConfig', Module.new)
    stub_const('PtoConfig::SCHEDULE', [
                 { path: '/pto/fetch_pto_from_notion.rb', time: ['13:10:00'], module: :PtoConfig },
                 { path: '/pto/humanize_pto.rb', time: ['13:20:00'], module: :PtoConfig },
                 { path: '/pto/garbage_collector.rb', time: ['13:30:00'], module: :PtoConfig },
                 { path: '/pto/notify_pto_in_discord.rb', time: ['13:40:00'], module: :PtoConfig }
               ])

    stub_const('PtoNextWeekConfig', Module.new)
    stub_const('PtoNextWeekConfig::SCHEDULE', [
                 { path: '/pto_next_week/fetch_next_week_pto_from_notion.rb', time: ['12:40:00'], day: ['Thursday'],
                   module: :PtoNextWeekConfig },
                 { path: '/pto_next_week/humanize_next_week_pto.rb', time: ['12:50:00'], day: ['Thursday'],
                   module: :PtoNextWeekConfig },
                 { path: '/pto_next_week/notify_next_week_pto_in_discord.rb', time: ['13:00:00'], day: ['Thursday'],
                   module: :PtoNextWeekConfig },
                 { path: '/pto_next_week/garbage_collector.rb', time: ['13:10:00'], day: ['Thursday'],
                   module: :PtoNextWeekConfig }
               ])

    stub_const('SupportEmailConfig', Module.new)
    stub_const('SupportEmailConfig::SCHEDULE', [
                 { path: '/support_email/fetch_emails_from_imap.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'],
                   module: :SupportEmailConfig },
                 { path: '/support_email/format_emails.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'],
                   module: :SupportEmailConfig },
                 { path: '/support_email/garbage_collector.rb', time: ['21:10:00'], module: :SupportEmailConfig },
                 { path: '/support_email/notify_support_emails.rb', time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'],
                   module: :SupportEmailConfig }
               ])

    stub_const('WebsitesAvailabilityConfig', Module.new)
    stub_const('WebsitesAvailabilityConfig::SCHEDULE', [
                 { path: '/websites_availability/fetch_domain_services_from_notion.rb', interval: 600_000,
                   module: :WebsitesAvailabilityConfig },
                 { path: '/websites_availability/notify_domain_availability.rb', interval: 60_000,
                   module: :WebsitesAvailabilityConfig },
                 { path: '/websites_availability/garbage_collector.rb', time: ['00:00:00'],
                   module: :WebsitesAvailabilityConfig },
                 { path: '/websites_availability/review_domain_availability.rb', interval: 60_000,
                   module: :WebsitesAvailabilityConfig }
               ])

    stub_const('WipLimitConfig', Module.new)
    stub_const('WipLimitConfig::SCHEDULE', [
                 { path: '/wip_limit/fetch_domains_wip_count.rb', time: ['12:20:00', '14:20:00', '18:20:00', '20:20:00'],
                   module: :WipLimitConfig },
                 { path: '/wip_limit/fetch_domains_wip_limit.rb', time: ['12:30:00', '14:30:00', '18:30:00', '20:30:00'],
                   module: :WipLimitConfig },
                 { path: '/wip_limit/compare_wip_limit_count.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'],
                   module: :WipLimitConfig },
                 { path: '/wip_limit/garbage_collector.rb', time: ['21:10:00'], module: :WipLimitConfig },
                 { path: '/wip_limit/format_wip_limit_exceeded.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'],
                   module: :WipLimitConfig },
                 { path: '/wip_limit/notify_domains_wip_limit_exceeded.rb',
                   time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'], module: :WipLimitConfig }
               ])

    # clean SCHEDULES constant before each test
    OrchestratorWithSchedules::Paths::SCHEDULES.clear
  end

  describe '.load_schedules' do
    it 'loads all schedules from modules' do
      # Execute the method to load the schedules
      OrchestratorWithSchedules::Paths.load_schedules

      # Verify if the schedules were loaded correctly
      expect(OrchestratorWithSchedules::Paths::SCHEDULES).to contain_exactly(
        { path: '/birthday_next_week/fetch_next_week_birthday_from_notion.rb', time: ['01:00:00'],
          module: :BirthdayNextWeekConfig },
        { path: '/birthday_next_week/format_next_week_birthday.rb', time: ['01:10:00'],
          module: :BirthdayNextWeekConfig },
        { path: '/birthday_next_week/garbage_collector.rb', time: ['13:00:00'], module: :BirthdayNextWeekConfig },
        { path: '/birthday_next_week/notify_next_week_birthday_in_discord.rb', time: ['13:10:00'],
          module: :BirthdayNextWeekConfig },
        { path: '/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb', interval: 300_000,
          module: :DigitalOceanBillAlertConfig },
        { path: '/digital_ocean_bill_alert/format_do_bill_alert.rb', interval: 300_000,
          module: :DigitalOceanBillAlertConfig },
        { path: '/digital_ocean_bill_alert/garbage_collector.rb', interval: 300_000,
          module: :DigitalOceanBillAlertConfig },
        { path: '/digital_ocean_bill_alert/notify_do_bill_alert_discord.rb', interval: 300_000,
          module: :DigitalOceanBillAlertConfig },
        { path: '/pto_next_week/fetch_next_week_pto_from_notion.rb', time: ['12:40:00'], day: ['Thursday'],
          module: :PtoNextWeekConfig },
        { path: '/pto_next_week/humanize_next_week_pto.rb', time: ['12:50:00'], day: ['Thursday'],
          module: :PtoNextWeekConfig },
        { path: '/pto_next_week/notify_next_week_pto_in_discord.rb', time: ['13:00:00'], day: ['Thursday'],
          module: :PtoNextWeekConfig },
        { path: '/pto_next_week/garbage_collector.rb', time: ['13:10:00'], day: ['Thursday'],
          module: :PtoNextWeekConfig },
        { path: '/wip_limit/fetch_domains_wip_count.rb', time: ['12:20:00', '14:20:00', '18:20:00', '20:20:00'],
          module: :WipLimitConfig },
        { path: '/wip_limit/fetch_domains_wip_limit.rb', time: ['12:30:00', '14:30:00', '18:30:00', '20:30:00'],
          module: :WipLimitConfig },
        { path: '/wip_limit/compare_wip_limit_count.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'],
          module: :WipLimitConfig },
        { path: '/wip_limit/garbage_collector.rb', time: ['21:10:00'], module: :WipLimitConfig },
        { path: '/wip_limit/format_wip_limit_exceeded.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'],
          module: :WipLimitConfig },
        { path: '/wip_limit/notify_domains_wip_limit_exceeded.rb',
          time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'], module: :WipLimitConfig },
        { path: '/support_email/fetch_emails_from_imap.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'],
          module: :SupportEmailConfig },
        { path: '/support_email/format_emails.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'],
          module: :SupportEmailConfig },
        { path: '/support_email/garbage_collector.rb', time: ['21:10:00'], module: :SupportEmailConfig },
        { path: '/support_email/notify_support_emails.rb', time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'],
          module: :SupportEmailConfig },
        { path: '/websites_availability/fetch_domain_services_from_notion.rb', interval: 600_000,
          module: :WebsitesAvailabilityConfig },
        { path: '/websites_availability/notify_domain_availability.rb', interval: 60_000,
          module: :WebsitesAvailabilityConfig },
        { path: '/websites_availability/garbage_collector.rb', time: ['00:00:00'],
          module: :WebsitesAvailabilityConfig },
        { path: '/websites_availability/review_domain_availability.rb', interval: 60_000,
          module: :WebsitesAvailabilityConfig },
        { path: '/pto/fetch_pto_from_notion.rb', time: ['13:10:00'], module: :PtoConfig },
        { path: '/pto/humanize_pto.rb', time: ['13:20:00'], module: :PtoConfig },
        { path: '/pto/garbage_collector.rb', time: ['13:30:00'], module: :PtoConfig },
        { path: '/pto/notify_pto_in_discord.rb', time: ['13:40:00'], module: :PtoConfig },
        { path: '/ospo_maintenance/create_work_item.rb', interval: 600_000, module: :OspoMaintenanceConfig },
        { path: '/ospo_maintenance/update_work_item.rb', interval: 600_000, module: :OspoMaintenanceConfig },
        { path: '/ospo_maintenance/verify_issue_existance_in_notion.rb', interval: 600_000,
          module: :OspoMaintenanceConfig },
        { path: '/birthday/fetch_birthday_from_notion.rb', time: ['01:00:00'], module: :BirthdayConfig },
        { path: '/birthday/format_birthday.rb', time: ['01:10:00'], module: :BirthdayConfig },
        { path: '/birthday/garbage_collector.rb', time: ['13:00:00'], module: :BirthdayConfig },
        { path: '/birthday/notify_birthday_in_discord.rb', time: ['13:10:00'], module: :BirthdayConfig }
      )
    end
  end
end
