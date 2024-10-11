# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/fetch_birthdays_from_notion'

module UseCase
  # FormatNextWeekBirthday
  #
  class FormatNextWeekBirthday < UseCase::Base
    TABLE = 'birthday'
    MESSAGE = ':birthday: :gift: The birthday of <name> will be in eight days! : <birthday_date>'

    def execute
      bot = Bot::FormatBirthdays.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchNextWeekBirthdaysFromNotion' },
        process_options: { template: MESSAGE },
        write_options: { connection:, db_table: TABLE, tag: 'FormatNextWeekBirthdays' }
      }
    end
  end
end
