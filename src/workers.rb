# frozen_string_literal: true

require_relative 'bots/birthday/fetch_birthday_from_notion'
require_relative 'bots/birthday/format_birthday'
require_relative 'bots/birthday/notify_birthday_in_discord'
require_relative 'bots/birthday_next_week/fetch_next_week_birthday_from_notion'
require_relative 'bots/birthday_next_week/format_next_week_birthday'
require_relative 'bots/birthday_next_week/notify_next_week_birthday_in_discord'

# Notify Birthday In Discord
class FetchBirthdayFromNotionWorker < UseCase::FetchBirthdayFromNotion; end
class FormatBirthdayWorker < UseCase::FormatBirthday; end
class NotifyBirthdayInDiscordWorker < UseCase::NotifyBirthdayInDiscord; end

# Notify Next Week Birthday In Discord
class FetchBirthdayFromNotionWorker < UseCase::FetchNextWeekBirthdayFromNotion; end
class FormatBirthdayWorker < UseCase::FormatNextWeekBirthday; end
class NotifyBirthdayInDiscordWorker < UseCase::NotifyNextWeekBirthdayInDiscord; end
