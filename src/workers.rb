# frozen_string_literal: true

# require_relative 'use_case/birthday/fetch_birthday_from_notion'
# require_relative 'use_case/birthday/format_birthday'
# require_relative 'use_case/birthday/notify_birthday_in_discord'

# require_relative 'use_case/birthday_next_week/fetch_next_week_birthday_from_notion'
# require_relative 'use_case/birthday_next_week/format_next_week_birthday'
# require_relative 'use_case/birthday_next_week/notify_next_week_birthday_in_discord'

# require_relative 'use_case/digital_ocean_bill_alert/fetch_billing_from_digital_ocean'
# require_relative 'use_case/digital_ocean_bill_alert/format_do_bill_alert'
# require_relative 'use_case/digital_ocean_bill_alert/notify_do_bill_alert_discord'

# require_relative 'use_case/ospo_maintenance/create_work_item'
# require_relative 'use_case/ospo_maintenance/update_work_item'
# require_relative 'use_case/ospo_maintenance/verify_issue_existance_in_notion'
# require_relative 'use_case/ospo_maintenance/projects/chaincerts_smart_contracts'
# require_relative 'use_case/ospo_maintenance/projects/bas'

# require_relative 'use_case/pto/fetch_pto_from_notion'
# require_relative 'use_case/pto/humanize_pto'
# require_relative 'use_case/pto/notify_pto_in_discord'

# require_relative 'use_case/pto_next_week/fetch_next_week_pto_from_notion'
# require_relative 'use_case/pto_next_week/humanize_next_week_pto'
# require_relative 'use_case/pto_next_week/notify_next_week_pto_in_discord'

# require_relative 'use_case/support_email/fetch_emails_from_imap'
# require_relative 'use_case/support_email/format_emails'
# require_relative 'use_case/support_email/notify_support_emails'

# require_relative 'use_case/websites_availability/fetch_domain_services_from_notion'
# require_relative 'use_case/websites_availability/notify_domain_availability'
# require_relative 'use_case/websites_availability/review_domain_availability'
# require_relative 'use_case/websites_availability/write_domain_review_requests'

# require_relative 'use_case/wip_limit/compare_wip_limit_count'
# require_relative 'use_case/wip_limit/fetch_domains_wip_limit'
# require_relative 'use_case/wip_limit/fetch_domains_wip_count'
# require_relative 'use_case/wip_limit/format_wip_limit_exceeded'
# require_relative 'use_case/wip_limit/notify_domains_wip_limit_exceeded'

# require_relative 'use_case/review_images/review_media'
# require_relative 'use_case/review_images/write_media_review_in_discord'

require_relative 'use_case/telegram_web_availability/fetch_websites_review_request'
require_relative 'use_case/telegram_web_availability/notify_telegram'
require_relative 'use_case/telegram_web_availability/review_website_availability'

# # Notify Birthday In Discord
# class FetchBirthdayFromNotionWorker < UseCase::FetchBirthdayFromNotion; end
# class FormatBirthdayWorker < UseCase::FormatBirthday; end
# class NotifyBirthdayInDiscordWorker < UseCase::NotifyBirthdayInDiscord; end

# # Notify Next Week Birthday In Discord
# class FetchNextWeekBirthdayFromNotionWorker < UseCase::FetchNextWeekBirthdayFromNotion; end
# class FormatNextWeekBirthdayWorker < UseCase::FormatNextWeekBirthday; end
# class NotifyNextWeekBirthdayInDiscordWorker < UseCase::NotifyNextWeekBirthdayInDiscord; end

# # Digital Ocean Bill Alert
# class FetchBillingFromDigitalOceanWorker < UseCase::FetchBillingFromDigitalOcean; end
# class FormatDoBillAlertWorker < UseCase::FormatDoBillAlert; end
# class NotifyDoBollAlertDiscordWorker < UseCase::NotifyDoBollAlertDiscord; end

# # OSPO Maintenance
# class CreateWorkItemWorker < UseCase::CreateWorkItem; end
# class UpdateWorkItemWorker < UseCase::UpdateWorkItem; end
# class VerifyIssueExistanceInNotionWorker < UseCase::VerifyIssueExistanceInNotion; end

# ## OSPO Maintenance repos
# class ChaincertsSmartContractsWorker < UseCase::ChaincertsSmartContracts; end
# class BasWorker < UseCase::Bas; end

# # PTO daily notification
# class FetchPtoFromNotionWorker < UseCase::FetchPtoFromNotion; end
# class HumanizePtoWorker < UseCase::HumanizePto; end
# class NotifyPtoInDiscordWorker < UseCase::NotifyPtoInDiscord; end

# # next week PTOs notification
# class FetchNextWeekPtoFromNotionWorker < UseCase::FetchNextWeekPtoFromNotion; end
# class HumanizeNextWeekPtoWorker < UseCase::HumanizeNextWeekPto; end
# class NotifyNextWeekPtoInDiscordWorker < UseCase::NotifyNextWeekPtoInDiscord; end

# # Support emails notification
# class FetchEmailsFromImapWorker < UseCase::FetchEmailsFromImap; end
# class FormatEmailsFromImapWorker < UseCase::FormatEmailsFromImap; end
# class NotifySupportEmailsWorker < UseCase::NotifySupportEmails; end

# # Webiste availability
# class FetchDomainServicesFromNotionWorker < UseCase::FetchDomainServicesFromNotion; end
# class WriteDomainReviewRequestsWorker < UseCase::WriteDomainReviewRequests; end
# class ReviewDomainAvailabilityWorker < UseCase::ReviewDomainAvailability; end
# class NotifyDomainAvailabilityWorker < UseCase::NotifyDomainAvailability; end

# # Domains WIP limit exceeded notification
# class FetchDomainsWipLimitFromNotionWorker < UseCase::FetchDomainsWipLimitFromNotion; end
# class FetchDomainsWipCountFromNotionWorker < UseCase::FetchDomainsWipCountFromNotion; end
# class CompareWipLimitCountWorker < UseCase::CompareWipLimitCount; end
# class FormatWipLimitExceededWorker < UseCase::FormatWipLimitExceeded; end
# class NotifyDomainsWipLimitExceededWorker < UseCase::NotifyDomainsWipLimitExceeded; end

# Review images (Discord Bot)
# class ReviewMediaWorker < UseCase::ReviewMedia; end
# class WriteMediaReviewInDiscordWorker < UseCase::WriteMediaReviewInDiscord; end

# Telegram Bot
class FetchWebsiteReviewRequestWorker < UseCase::FetchWebsiteReviewRequest; end
class NotifyTelegramWorker < UseCase::NotifyTelegram; end
class ReviewWebsiteAvailabilityWorker < UseCase::ReviewWebsiteAvailability; end
