# frozen_string_literal: true

require_relative '../base'

require 'bas/bot/humanize_pto'

module UseCase
  # HumanizePto
  #
  class HumanizePto < UseCase::Base
    TABLE = 'pto'

    def execute
      bot = Bot::HumanizePto.new(options)

      bot.execute
    end

    private

    def options
      {
        read_options: { connection:, db_table: TABLE, tag: 'FetchPtosFromNotion' },
        process_options: { secret:, assistant_id:, prompt: },
        write_options: { connection:, db_table: TABLE, tag: 'HumanizePto' }
      }
    end

    def prompt
      utc_today = Time.now.utc
      today = Time.at(utc_today, in: '-05:00').strftime('%A, %B %m of %Y').to_s

      "Today is #{today} and the PTO's are: {data}. Notify only todays information"
    end

    def secret
      ENV.fetch('OPENAI_SECRET')
    end

    def assistant_id
      ENV.fetch('PTO_OPENAI_ASSISTANT')
    end
  end
end
