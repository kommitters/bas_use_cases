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
    def self.load
      constants.map { |const| const_get(const) }.flatten
    end

    path_to_repo = '../../../../../../../../../'
    scripts_path = "#{path_to_repo}src/use_cases_execution"

    BIRTHDAY_SCHEDULES = [
      { path: "#{scripts_path}/birthday/fetch_birthday_from_notion.rb", time: ['12:40'] },
      { path: "#{scripts_path}/birthday/format_birthday.rb", time: ['12:50'] },
      { path: "#{scripts_path}/birthday/notify_birthday_in_discord.rb", time: ['13:00'] },
      { path: "#{scripts_path}/birthday/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    BIRTHDAY_NEXT_WEEK_SCHEDULES = [
      { path: "#{scripts_path}/birthday_next_week/fetch_next_week_birthday_from_notion.rb", time: ['12:40'] },
      { path: "#{scripts_path}/birthday_next_week/format_next_week_birthday.rb", time: ['12:50'] },
      { path: "#{scripts_path}/birthday_next_week/notify_next_week_birthday_in_discord.rb", time: ['13:00'] },
      { path: "#{scripts_path}/birthday_next_week/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    DIGITAL_OCEAN_BILL_ALERT_SCHEDULES = [
      { path: "#{scripts_path}/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb", interval: 10_000 },
      { path: "#{scripts_path}/digital_ocean_bill_alert/format_do_bill_alert.rb", interval: 10_000 },
      { path: "#{scripts_path}/digital_ocean_bill_alert/notify_do_bill_alert_discord.rb", interval: 10_000 },
      { path: "#{scripts_path}/digital_ocean_bill_alert/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    PTO_SCHEDULES = [
      { path: "#{scripts_path}/pto/fetch_pto_from_notion.rb", time: ['13:10'] },
      { path: "#{scripts_path}/pto/humanize_pto.rb", time: ['13:20'] },
      { path: "#{scripts_path}/pto/notify_pto_in_discord.rb", time: ['13:30'] },
      { path: "#{scripts_path}/pto/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    PTO_NEXT_WEEK_SCHEDULES = [
      { path: "#{scripts_path}/pto_next_week/fetch_next_week_pto_from_notion.rb", time: ['12:40'], day: ['Thursday'] },
      { path: "#{scripts_path}/pto_next_week/humanize_next_week_pto.rb", time: ['12:50'], day: ['Thursday'] },
      { path: "#{scripts_path}/pto_next_week/notify_next_week_pto_in_discord.rb", time: ['13:00'], day: ['Thursday'] },
      { path: "#{scripts_path}/pto_next_week/garbage_collector.rb", time: ['00:00'], day: ['Thursday'] }
    ].freeze

    SUPPORT_EMAIL_SCHEDULES = [
      { path: "#{scripts_path}/support_email/fetch_emails_from_imap.rb", time: ['12:40', '14:40', '18:40', '20:40'] },
      { path: "#{scripts_path}/support_email/format_emails.rb", time: ['12:50', '14:50', '18:50', '20:50'] },
      { path: "#{scripts_path}/support_email/garbage_collector.rb", time: ['21:10'] },
      { path: "#{scripts_path}/support_email/notify_support_emails.rb", time: ['13:00', '15:00', '19:00', '21:00'] }
    ].freeze

    WIP_LIMIT_SCHEDULES = [
      { path: "#{scripts_path}/wip_limit/fetch_domains_wip_count.rb", time: ['12:20', '14:20', '18:20', '20:20'] },
      { path: "#{scripts_path}/wip_limit/fetch_domains_wip_limit.rb", time: ['12:30', '14:30', '18:30', '20:30'] },
      { path: "#{scripts_path}/wip_limit/compare_wip_limit_count.rb", time: ['12:40', '14:40', '18:40', '20:40'] },
      { path: "#{scripts_path}/wip_limit/garbage_collector.rb", time: ['21:10'] },
      { path: "#{scripts_path}/wip_limit/format_wip_limit_exceeded.rb", time: ['12:50', '14:50', '18:50', '20:50'] },
      { path: "#{scripts_path}/wip_limit/notify_domains_wip_limit_exceeded.rb",
        time: ['13:00', '15:00', '19:00', '21:00'] }
    ].freeze

    SAVE_BACKUP = [
      { path: "#{scripts_path}/save_backup/save_backup_in_r2.rb", time: ['00:00'] },
      { path: "#{scripts_path}/save_backup/delete_older_backup_in_r2.rb", time: ['00:20'] }
    ].freeze
  end
end
