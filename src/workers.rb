# frozen_string_literal: true

require_relative 'bots/birthday/fetch_birthday_from_notion'
require_relative 'bots/birthday/format_birthday'
require_relative 'bots/birthday/notify_birthday_in_discord'

require_relative 'bots/birthday_next_week/fetch_next_week_birthday_from_notion'
require_relative 'bots/birthday_next_week/format_next_week_birthday'
require_relative 'bots/birthday_next_week/notify_next_week_birthday_in_discord'

require_relative 'bots/digital_ocean_bill_alert/fetch_billing_from_digital_ocean'
require_relative 'bots/digital_ocean_bill_alert/format_do_bill_alert'
require_relative 'bots/digital_ocean_bill_alert/notify_do_bill_alert_discord'

require_relative 'bots/ospo_maintenance/create_work_item'
require_relative 'bots/ospo_maintenance/update_work_item'
require_relative 'bots/ospo_maintenance/verify_issue_existance_in_notion'
require_relative 'bots/ospo_maintenance/projects/chaincerts_smart_contracts'

require_relative 'bots/pto/fetch_pto_from_notion'
require_relative 'bots/pto/humanize_pto'
require_relative 'bots/pto/notify_pto_in_discord'

require_relative 'bots/pto_next_week/fetch_next_week_pto_from_notion'
require_relative 'bots/pto_next_week/humanize_next_week_pto'
require_relative 'bots/pto_next_week/notify_next_week_pto_in_discord'

require_relative 'bots/support_email/fetch_emails_from_imap'
require_relative 'bots/support_email/format_emails'
require_relative 'bots/support_email/notify_support_emails'

require_relative 'bots/websites_availability/fetch_domain_services_from_notion'
require_relative 'bots/websites_availability/notify_domain_availability'
require_relative 'bots/websites_availability/review_domain_availability'
require_relative 'bots/websites_availability/write_domain_review_requests'

require_relative 'bots/wip_limit/compare_wip_limit_count'
require_relative 'bots/wip_limit/fetch_domains_wip_limit'
require_relative 'bots/wip_limit/fetch_domains_wip_count'
require_relative 'bots/wip_limit/format_wip_limit_exceeded'
require_relative 'bots/wip_limit/notify_domains_wip_limit_exceeded'

# Notify Birthday In Discord
class FetchBirthdayFromNotionWorker < UseCase::FetchBirthdayFromNotion; end
class FormatBirthdayWorker < UseCase::FormatBirthday; end
class NotifyBirthdayInDiscordWorker < UseCase::NotifyBirthdayInDiscord; end

# Notify Next Week Birthday In Discord
class FetchNextWeekBirthdayFromNotionWorker < UseCase::FetchNextWeekBirthdayFromNotion; end
class FormatNextWeekBirthdayWorker < UseCase::FormatNextWeekBirthday; end
class NotifyNextWeekBirthdayInDiscordWorker < UseCase::NotifyNextWeekBirthdayInDiscord; end

# Digital Ocean Bill Alert
class FetchBillingFromDigitalOceanWorker < UseCase::FetchBillingFromDigitalOcean; end
class FormatDoBillAlertWorker < UseCase::FormatDoBillAlert; end
class NotifyDoBollAlertDiscordWorker < UseCase::NotifyDoBollAlertDiscord; end

# OSPO Maintenance
class CreateWorkItemWorker < UseCase::CreateWorkItem; end
class UpdateWorkItemWorker < UseCase::UpdateWorkItem; end
class VerifyIssueExistanceInNotionWorker < UseCase::VerifyIssueExistanceInNotion; end

## OSPO Maintenance repos
class FetchChaincertsSmartContractsIssuesWorker < UseCase::FetchChaincertsSmartContractsIssues; end

# PTO daily notification
class FetchPtoFromNotionWorker < UseCase::FetchPtoFromNotion; end
class HumanizePtoWorker < UseCase::HumanizePto; end
class NotifyPtoInDiscordWorker < UseCase::NotifyPtoInDiscord; end

# next week PTOs notification
class FetchNextWeekPtoFromNotionWorker < UseCase::FetchNextWeekPtoFromNotion; end
class HumanizeNextWeekPtoWorker < UseCase::HumanizeNextWeekPto; end
class NotifyNextWeekPtoInDiscordWorker < UseCase::NotifyNextWeekPtoInDiscord; end

# Support emails notification
class FetchNextWeekPtoFromNotionWorker < UseCase::FetchEmailsFromImap; end
class FetchNextWeekPtoFromNotionWorker < UseCase::FormatEmailsFromImap; end
class FetchNextWeekPtoFromNotionWorker < UseCase::NotifySupportEmails; end

# Webiste availability
class FetchDomainServicesFromNotionWorker < UseCase::FetchDomainServicesFromNotion; end
class WriteDomainReviewRequestsWorker < UseCase::WriteDomainReviewRequests; end
class ReviewDomainAvailabilityWorker < UseCase::ReviewDomainAvailability; end
class NotifyDomainAvailabilityWorker < UseCase::NotifyDomainAvailability; end

# Domains WIP limit exceeded notification
class NotifyDomainAvailabilityWorker < UseCase::FetchDomainsWipLimitFromNotion; end
class NotifyDomainAvailabilityWorker < UseCase::FetchDomainsWipCountFromNotion; end
class NotifyDomainAvailabilityWorker < UseCase::CompareWipLimitCount; end
class NotifyDomainAvailabilityWorker < UseCase::FormatWipLimitExceeded; end
class NotifyDomainAvailabilityWorker < UseCase::NotifyDomainsWipLimitExceeded; end
