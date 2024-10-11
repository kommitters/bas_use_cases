# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/humanize_pto'

module UseCase
  # HumanizePto
  #
  class HumanizePto < UseCase::Base
    TABLE = 'pto'
    OPENAI_SECRET = ENV.fetch('OPENAI_SECRET')
    PTO_OPENAI_ASSISTANT = ENV.fetch('PTO_OPENAI_ASSISTANT')

    def execute
      bot = Bot::HumanizePto.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchPtosFromNotion' },
        process_options: { secret: OPENAI_SECRET, assistant_id: PTO_OPENAI_ASSISTANT, prompt: },
        write_options: { connection:, db_table: TABLE, tag: 'HumanizePto' }
      }
    end

    def prompt
      utc_today = Time.now.utc
      today = Time.at(utc_today, in: '-05:00').strftime('%A, %B %m of %Y').to_s

      "Today is #{today} and the PTO's are: {data}. Notify only todays information"
    end
  end
end
