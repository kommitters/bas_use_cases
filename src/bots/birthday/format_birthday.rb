# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/format_birthdays'

module UseCase
  # UseCase::FormatBirthday
  #
  class FormatBirthday < UseCase::Base
    TABLE = 'birthday'
    MESSAGE = 'Wishing you a very happy birthday! Enjoy your special day! :birthday: :gift:'

    def perform
      bot = Bot::FormatBirthdays.new(options)

      bot.execute
    rescue StandardError => e
      Logger.new($stdout).info(e.message)
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchBirthdaysFromNotion' },
        process_options: { template: "<name>, #{MESSAGE}" },
        write_options: { connection:, db_table: TABLE, tag: 'FormatBirthdays' }
      }
    end
  end
end
