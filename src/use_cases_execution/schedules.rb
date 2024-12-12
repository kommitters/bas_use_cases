# frozen_string_literal: true

module UseCasesExecution
  ##
  # This module contains the schedules for the scripts that will be executed by the orchestrator.
  # Each schedule is a hash with the following
  # keys:
  # path: The path to the script that will
  # time: The time when the script will be executed
  # day: The day when the script will be executed
  module Schedules
    def self.schedules
      constants.reduce([]) { |schedules, schedule| schedules + const_get(schedule) }
    end

    BIRTHDAY_SCHEDULES = [
      { path: '/birthday/fetch_birthday_from_notion.rb', time: ['12:40:00'] },
      { path: '/birthday/format_birthday.rb', time: ['12:50:00'] },
      { path: '/birthday/notify_birthday_in_discord.rb', time: ['13:00:00'] },
      { path: '/birthday/garbage_collector.rb', time: ['00:00:00'] }
    ].freeze

    BIRTHDAY_NEXT_WEEK_SCHEDULES = [
      { path: '/birthday_next_week/fetch_next_week_birthday_from_notion.rb', time: ['12:40:00'] },
      { path: '/birthday_next_week/format_next_week_birthday.rb', time: ['12:50:00'] },
      { path: '/birthday_next_week/notify_next_week_birthday_in_discord.rb', time: ['13:00:00'] },
      { path: '/birthday_next_week/garbage_collector.rb', time: ['00:00:00'] }
    ].freeze

    DIGITAL_OCEAN_BILL_ALERT_SCHEDULES = [
      { path: '/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb', interval: 10_000 },
      { path: '/digital_ocean_bill_alert/format_do_bill_alert.rb', interval: 10_000 },
      { path: '/digital_ocean_bill_alert/notify_do_bill_alert_discord.rb', interval: 10_000 },
      { path: '/digital_ocean_bill_alert/garbage_collector.rb', time: ['00:00:00'] }
    ].freeze

    PTO_SCHEDULES = [
      { path: '/pto/fetch_pto_from_notion.rb', time: ['13:10:00'] },
      { path: '/pto/humanize_pto.rb', time: ['13:20:00'] },
      { path: '/pto/notify_pto_in_discord.rb', time: ['13:30:00'] },
      { path: '/pto/garbage_collector.rb', time: ['00:00:00'] }
    ].freeze

    PTO_NEXT_WEEK_SCHEDULES = [
      { path: '/pto_next_week/fetch_next_week_pto_from_notion.rb', time: ['12:40:00'], day: ['Thursday'] },
      { path: '/pto_next_week/humanize_next_week_pto.rb', time: ['12:50:00'], day: ['Thursday'] },
      { path: '/pto_next_week/notify_next_week_pto_in_discord.rb', time: ['13:00:00'], day: ['Thursday'] },
      { path: '/pto_next_week/garbage_collector.rb', time: ['00:00:00'], day: ['Thursday'] }
    ].freeze

    SUPPORT_EMAIL_SCHEDULES = [
      { path: '/support_email/fetch_emails_from_imap.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'] },
      { path: '/support_email/format_emails.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'] },
      { path: '/support_email/garbage_collector.rb', time: ['21:10:00'] },
      { path: '/support_email/notify_support_emails.rb', time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'] }
    ].freeze

    WEBSITES_AVAILABILITY_SCHEDULES = [
      { path: '/websites_availability/fetch_domain_services_from_notion.rb', interval: 60_000 },
      { path: '/websites_availability/review_domain_availability.rb', interval: 5_000 },
      { path: '/websites_availability/notify_domain_availability.rb', interval: 5_000 },
      { path: '/websites_availability/garbage_collector.rb', time: ['00:00:00'] }
    ].freeze

    WIP_LIMIT_SCHEDULES = [
      { path: '/wip_limit/fetch_domains_wip_count.rb', time: ['12:20:00', '14:20:00', '18:20:00', '20:20:00'] },
      { path: '/wip_limit/fetch_domains_wip_limit.rb', time: ['12:30:00', '14:30:00', '18:30:00', '20:30:00'] },
      { path: '/wip_limit/compare_wip_limit_count.rb', time: ['12:40:00', '14:40:00', '18:40:00', '20:40:00'] },
      { path: '/wip_limit/garbage_collector.rb', time: ['21:10:00'] },
      { path: '/wip_limit/format_wip_limit_exceeded.rb', time: ['12:50:00', '14:50:00', '18:50:00', '20:50:00'] },
      { path: '/wip_limit/notify_domains_wip_limit_exceeded.rb',
        time: ['13:00:00', '15:00:00', '19:00:00', '21:00:00'] }
    ].freeze

    SAVE_BACKUP = [
      { path: '/save_backup/save_backup_in_r2.rb', time: ['00:00'] },
      { path: '/save_backup/delete_older_backup_in_r2.rb', time: ['00:10'] }
    ].freeze
  end
end
