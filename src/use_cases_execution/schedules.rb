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

    BIRTHDAY_SCHEDULES = [
      { path: "#{__dir__}/birthday/format_birthday_workspace.rb", time: ['12:55'] },
      { path: "#{__dir__}/birthday/notify_birthday_in_workspace.rb", time: ['13:05'] },
      { path: "#{__dir__}/birthday/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    BIRTHDAY_NEXT_WEEK_SCHEDULES = [
      { path: "#{__dir__}/birthday_next_week/format_next_week_birthday_workspace.rb", time: ['12:55'] },
      { path: "#{__dir__}/birthday_next_week/notify_next_week_birthday_in_workspace.rb", time: ['13:05'] },
      { path: "#{__dir__}/birthday_next_week/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    DIGITAL_OCEAN_BILL_ALERT_SCHEDULES = [
      { path: "#{__dir__}/digital_ocean_bill_alert/fetch_billing_from_digital_ocean.rb", interval: 10_000 },
      { path: "#{__dir__}/digital_ocean_bill_alert/format_do_bill_alert.rb", interval: 10_000 },
      { path: "#{__dir__}/digital_ocean_bill_alert/notify_do_bill_alert_workspace.rb", interval: 10_000 },
      { path: "#{__dir__}/digital_ocean_bill_alert/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    PTO_SCHEDULES = [
      { path: "#{__dir__}/pto/humanize_pto_workspace.rb", time: ['13:25'] },
      { path: "#{__dir__}/pto/notify_pto_in_workspace.rb", time: ['13:35'] },
      { path: "#{__dir__}/pto/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    PTO_NEXT_WEEK_SCHEDULES = [
      { path: "#{__dir__}/pto_next_week/humanize_next_week_pto_workspace.rb", time: ['12:55'], day: ['Thursday'] },
      { path: "#{__dir__}/pto_next_week/notify_pto_next_week_in_workspace.rb", time: ['13:05'], day: ['Thursday'] },
      { path: "#{__dir__}/pto_next_week/garbage_collector.rb", time: ['23:00'], day: ['Thursday'] }
    ].freeze

    SUPPORT_EMAIL_SCHEDULES = [
      { path: "#{__dir__}/support_email/fetch_emails_from_imap.rb", time: ['12:40', '14:40', '18:40', '20:40'] },
      { path: "#{__dir__}/support_email/format_emails.rb", time: ['12:50', '14:50', '18:50', '20:50'] },
      { path: "#{__dir__}/support_email/garbage_collector.rb", time: ['21:10'] },
      { path: "#{__dir__}/support_email/notify_support_emails.rb", time: ['13:00', '15:00', '19:00', '21:00'] }
    ].freeze

    WIP_LIMIT_SCHEDULES = [
      { path: "#{__dir__}/wip_limit/fetch_domains_wip_count.rb", time: ['12:20', '14:20', '18:20', '20:20'] },
      { path: "#{__dir__}/wip_limit/fetch_domains_wip_limit.rb", time: ['12:30', '14:30', '18:30', '20:30'] },
      { path: "#{__dir__}/wip_limit/compare_wip_limit_count.rb", time: ['12:40', '14:40', '18:40', '20:40'] },
      { path: "#{__dir__}/wip_limit/garbage_collector.rb", time: ['21:10'] },
      { path: "#{__dir__}/wip_limit/format_wip_limit_exceeded.rb", time: ['12:50', '14:50', '18:50', '20:50'] },
      { path: "#{__dir__}/wip_limit/notify_domains_wip_limit_exceeded.rb",
        time: ['13:00', '15:00', '19:00', '21:00'] }
    ].freeze

    SAVE_BACKUP = [
      { path: "#{__dir__}/save_backup/save_backup_in_r2.rb", time: ['00:00'] },
      { path: "#{__dir__}/save_backup/delete_older_backup_in_r2.rb", time: ['00:20'] }
    ].freeze

    MISSING_WORK_LOGS_SCHEDULES = [
      { path: "#{__dir__}/missing_work_logs/fetch_people_with_missing_logs.rb", time: ['13:20'] },
      { path: "#{__dir__}/missing_work_logs/notify_missing_work_logs.rb", interval: 300_000 },
      { path: "#{__dir__}/missing_work_logs/garbage_collector.rb", time: ['14:00'] }
    ].freeze

    APOLLO_SYNC_SCHEDULE = [
      { path: "#{__dir__}/networks_sync/fetch_new_networks_from_apollo.rb", day: 'Sunday', time: ['10:00'] },
      { path: "#{__dir__}/networks_sync/update_new_networks_in_notion.rb", day: 'Sunday', time: ['10:10'] },
      { path: "#{__dir__}/networks_sync/fetch_networks_emailless_from_notion.rb", day: 'Sunday', time: ['10:15'] },
      { path: "#{__dir__}/networks_sync/search_users_in_apollo.rb", day: 'Sunday', time: ['11:00'] },
      { path: "#{__dir__}/networks_sync/update_networks.rb", day: 'Sunday', time: ['11:10'] },
      { path: "#{__dir__}/sync_brevo/fetch_networks_from_notion.rb", day: 'Sunday', time: ['11:20'] },
      { path: "#{__dir__}/sync_brevo/update_brevo_contacts.rb", day: 'Sunday', time: ['11:30'] }
    ].freeze

    OSS_SCORE_SCHEDULES = [
      { path: "#{__dir__}/oss_score/fetch_repositories_from_notion.rb", time: ['17:40'], day: ['Friday'] },
      { path: "#{__dir__}/oss_score/fetch_scores_from_github.rb", time: ['17:50'], day: ['Friday'] },
      { path: "#{__dir__}/oss_score/update_scores_in_notion.rb", time: ['18:00'], day: ['Friday'] }
    ].freeze

    OSPO_CLOSED_ISSUES_KPI_SCHEDULES = [
      { path: "#{__dir__}/closed_issues/fetch_github_issues.rb", custom_rule: {
        type: 'last_day_of_month',
        time: ['12:00']
      } },
      { path: "#{__dir__}/closed_issues/insert_github_issues_in_notion_db.rb", custom_rule: {
        type: 'last_day_of_month',
        time: ['12:10']
      } }
    ].freeze

    OSPO_PROJECT_ISSUES = [
      { path: "#{__dir__}/ospo_maintenance/projects/bas.rb", time: ['08:00', '11:00', '14:00', '17:00', '20:00'] },
      { path: "#{__dir__}/ospo_maintenance/projects/bas_use_cases.rb",
        time: ['08:01', '11:01', '14:01', '17:01', '20:01'] },
      { path: "#{__dir__}/ospo_maintenance/projects/chaincerts_dapp.rb", time: ['18:00'] },
      { path: "#{__dir__}/ospo_maintenance/projects/chaincerts_prototype.rb", time: ['18:01'] },
      { path: "#{__dir__}/ospo_maintenance/projects/chaincerts_smart_contracts.rb", time: ['18:02'] },
      { path: "#{__dir__}/ospo_maintenance/projects/editorjs_break_line.rb", time: ['18:03'] },
      { path: "#{__dir__}/ospo_maintenance/projects/editorjs_drag_drop.rb", time: ['18:04'] },
      { path: "#{__dir__}/ospo_maintenance/projects/editorjs_inline_image.rb", time: ['18:05'] },
      { path: "#{__dir__}/ospo_maintenance/projects/editorjs_toggle_block.rb", time: ['18:06'] },
      { path: "#{__dir__}/ospo_maintenance/projects/editorjs_tooltip.rb", time: ['18:07'] },
      { path: "#{__dir__}/ospo_maintenance/projects/editor_js_undo.rb", time: ['18:08'] },
      { path: "#{__dir__}/ospo_maintenance/projects/elixir_xdr.rb", time: ['18:09'] },
      { path: "#{__dir__}/ospo_maintenance/projects/kadena_ex.rb", time: ['18:10'] },
      { path: "#{__dir__}/ospo_maintenance/projects/mintacoin.rb", time: ['18:11'] },
      { path: "#{__dir__}/ospo_maintenance/projects/mtk_automation.rb", time: ['18:12'] },
      { path: "#{__dir__}/ospo_maintenance/projects/soroban_ex.rb", time: ['18:13'] },
      { path: "#{__dir__}/ospo_maintenance/projects/soroban_smart_contracts.rb", time: ['18:14'] },
      { path: "#{__dir__}/ospo_maintenance/projects/stellar_base.rb", time: ['18:15'] },
      { path: "#{__dir__}/ospo_maintenance/projects/stellar_sdk.rb", time: ['18:16'] },
      { path: "#{__dir__}/ospo_maintenance/projects/tickspot_js.rb", time: ['18:17'] }
    ].freeze

    EXPIRED_PROJECTS_SCHEDULES = [
      { path: "#{__dir__}/expired_projects/fetch_expired_projects.rb", time: ['12:40'] },
      { path: "#{__dir__}/expired_projects/format_expired_projects.rb", time: ['12:50'] },
      { path: "#{__dir__}/expired_projects/notify_expired_projects_in_workspace.rb", time: ['13:00'] },
      { path: "#{__dir__}/expired_projects/garbage_collector.rb", time: ['00:00'] }
    ].freeze

    GITHUB_NOTION_ISSUES_SYNC_SCHEDULES = [
      { path: "#{__dir__}/github_notion_issues_sync/format_github_issues.rb",
        time: ['08:10', '11:10', '14:10', '17:10', '20:10'] },
      { path: "#{__dir__}/github_notion_issues_sync/create_or_update_issues.rb",
        time: ['08:15', '11:15', '14:15', '17:15', '20:15'] },
      { path: "#{__dir__}/github_notion_issues_sync/garbage_collector.rb", time: ['21:05'] }
    ].freeze

    NOTION_WAREHOUSE_SYNC_SCHEDULES = [
      { path: "#{__dir__}/warehouse/notion/fetch_domains.rb", time: ['05:00'] },
      { path: "#{__dir__}/warehouse/notion/fetch_documents.rb", time: ['05:05'] },
      { path: "#{__dir__}/warehouse/notion/fetch_key_results.rb", time: ['05:10'] },
      { path: "#{__dir__}/warehouse/notion/fetch_projects.rb", time: ['05:15'] },
      { path: "#{__dir__}/warehouse/notion/fetch_milestones.rb", time: ['05:20'] },
      { path: "#{__dir__}/warehouse/notion/fetch_activities.rb", time: ['05:25'] },
      { path: "#{__dir__}/warehouse/notion/fetch_persons.rb", time: ['05:30'] },
      { path: "#{__dir__}/warehouse/notion/fetch_hired_persons.rb", time: ['05:35'] },
      { path: "#{__dir__}/warehouse/notion/fetch_weekly_scopes.rb", time: ['05:40'] },
      { path: "#{__dir__}/warehouse/notion/fetch_work_items.rb", time: ['05:45'] },
      { path: "#{__dir__}/warehouse/notion/fetch_kpis.rb", time: ['05:50'] },
      { path: "#{__dir__}/warehouse/worklogs/fetch_work_logs.rb", time: ['05:55'] },
      { path: "#{__dir__}/warehouse/github/fetch_kommit_co_releases_from_github.rb", time: ['06:00'] },
      { path: "#{__dir__}/warehouse/github/fetch_kommitters_releases_from_github.rb", time: ['06:05'] },
      { path: "#{__dir__}/warehouse/github/fetch_kommit_co_issues_from_github.rb", time: ['06:10'] },
      { path: "#{__dir__}/warehouse/github/fetch_kommitters_issues_from_github.rb", time: ['06:15'] },
      { path: "#{__dir__}/warehouse/github/fetch_kommit_co_pull_requests_from_github.rb", time: ['06:20'] },
      { path: "#{__dir__}/warehouse/github/fetch_kommitters_pull_requests_from_github.rb", time: ['06:25'] },
      { path: "#{__dir__}/warehouse/warehouse_ingester.rb", interval: 3_600_000 }
    ].freeze
  end
end
