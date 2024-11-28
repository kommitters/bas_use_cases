#frozen_string_literal: true

=begin
  INSTRUCTIONS:

  This file is used to store the configuration of the birthday use case.
  It contains the connection information to the database and the schedule of the bot.
  The schedule configuration has two fields: path and interval.
  The path is the path to the script that will be executed
  The interval is the time in milliseconds that the script will be executed
=end

require 'dotenv/load'

module Paths
  SCHEDULE = [
    #birthday use case
    { path: "/birthday/fetch_birthday_from_notion.rb", interval: 1000 },
    { path: "/birthday/format_birthday.rb", interval: 1000 },
    { path: "/birthday/garbage_collector.rb", interval: 1000},
    { path: "/birthday/notify_birthday_in_discord.rb", interval: 1000},
    #birthday_next_week use case
    { path: "/birthday_next_week/fetch_next_week_birthday_from_notion.rb", interval: 1000 },
    { path: "/birthday_next_week/format_next_week_birthday.rb", interval: 1000},
    { path: "/birthday_next_week/garbage_collector.rb", interval: 1000},
    { path: "/birthday_next_week/notify_next_week_birthday_in_discord.rb", interval: 1000},
    #digital_ocean_bill_alert use case
    { path: "/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb", interval: 1000 },
    { path: "/digital_ocean_bill_alert/format_do_bill_alert.rb", interval: 1000},
    { path: "/digital_ocean_bill_alert/garbage_collector.rb", interval: 1000},
    { path: "/digital_ocean_bill_alert/notify_do_bill_alert_discord.rb", interval: 1000},
    #ospo_maintenance use case
    { path: "/ospo_maintenance/create_work_item.rb", interval: 1000 },
    { path: "/ospo_maintenance/update_work_item.rb", interval: 1000},
    { path: "/ospo_maintenance/verify_issue_existance_in_notion.rb", interval: 1000},
    #pto use case
    { path: "/pto/fetch_pto_from_notion.rb", interval: 1000 },
    { path: "/pto/humanize_pto.rb", interval: 1000},
    { path: "/pto/garbage_collector.rb", interval: 1000},
    { path: "/pto/notify_pto_in_discord.rb", interval: 1000},
    #pto_next_week use case
    { path: "/pto_next_week/fetch_next_week_pto_from_notion.rb", interval: 1000 },
    { path: "/pto_next_week/humanize_next_week_pto.rb", interval: 1000},
    { path: "/pto_next_week/garbage_collector.rb", interval: 1000},
    { path: "/pto_next_week/notify_next_week_pto_in_discord.rb", interval: 1000},
    #support_email use case
    { path: "/support_email/fetch_emails_from_imap.rb", interval: 1000 },
    { path: "/support_email/format_emails.rb", interval: 1000},
    { path: "/support_email/garbage_collector.rb", interval: 1000},
    { path: "/support_email/notify_support_emails.rb", interval: 1000},
    #websites_availability use case
    { path: "/websites_availability/fetch_domain_services_from_notion.rb", interval: 1000 },
    { path: "/websites_availability/notify_domain_availability.rb", interval: 1000 },
    { path: "/websites_availability/garbage_collector.rb", interval: 1000 },
    { path: "/websites_availability/review_domain_availability.rb", interval: 1000 },
    #wip_limit use case
    { path: "/wip_limit/fetch_domains_wip_count.rb", interval: 1000 },
    { path: "/wip_limit/fetch_domains_wip_limit.rb", interval: 1000 },
    { path: "/wip_limit/compare_wip_limit_count.rb", interval: 1000 },
    { path: "/wip_limit/garbage_collector.rb", interval: 1000 },
    { path: "/wip_limit/format_wip_limit_exceeded.rb", interval: 1000 },
    { path: "/wip_limit/notify_domains_wip_limit_exceeded.rb", interval: 1000},
  ].freeze
end
