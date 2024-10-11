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
