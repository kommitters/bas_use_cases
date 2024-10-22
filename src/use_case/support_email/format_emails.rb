# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/format_emails'

module UseCase
  # FormatEmailsFromImap
  #
  class FormatEmailsFromImap < UseCase::Base
    TABLE = 'support_emails'
    TEMPLATE = 'The <sender> has requested support the <date>'

    def execute
      bot = Bot::FormatEmails.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchEmailsFromImap' },
        process_options: { template: TEMPLATE, timezone: '-05:00', frequency: notification_frequency },
        write_options: { connection:, db_table: TABLE, tag: 'FormatEmails' }
      }
    end

    def notification_frequency
      current_time = Time.now.utc

      return 16 if current_time < target_hour(13)
      return 3 if current_time < target_hour(16)
      return 5 if current_time < target_hour(21)

      24
    end

    def target_hour(hour)
      current_time = Time.now.utc

      Time.utc(current_time.year, current_time.month, current_time.day, hour, 1, 0)
    end
  end
end
