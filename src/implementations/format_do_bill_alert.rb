# frozen_string_literal: true

require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FormatDoBillAlert class serves as a bot implementation to format DigitalOcean bill
  # alerts from a PostgresDB database, format them with a specific template, and write them on a
  # PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "do_billing",
  #     tag: "FetchBillingFromDigitalOcean"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "do_billing",
  #     tag: "FormatDoBillAlert"
  #   }
  #
  #   options = {
  #     threshold: 7
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FormatDoBillAlert.new(options, shared_storage).execute
  #
  class FormatDoBillAlert < Bas::Bot::Base
    # Process function to format the notification using a template
    #
    def process
      return { success: { notification: '' } } if unprocessable_response || !threshold_exceeded

      { success: { notification: message } }
    end

    private

    def threshold_exceeded
      return false if billing.zero?

      usage > process_options[:threshold]
    end

    def usage
      billing - last_billing
    end

    def billing
      read_response.data['billing']['month_to_date_balance'].to_f
    end

    def last_billing
      read_response.data['last_billing']['month_to_date_balance'].to_f
    end

    def message
      balance = billing
      threshold = process_options[:threshold]

      ":warning: The **DigitalOcean** daily usage was exceeded. \n
      -Current balance: #{balance}\n
      -Threshold: #{threshold}\n
      -Current daily usage: #{usage.round(3)}"
    end
  end
end
