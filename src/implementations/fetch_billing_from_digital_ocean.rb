# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/digital_ocean/request'

module Implementation
  ##
  # The Implementation::FetchBillingFromDigitalOcean class serves as a bot implementation to read digital
  # ocean current billing using the DigitalOcean API
  #
  # <br>
  # <b>Example</b>
  #
  #  read_options = {
  #    connection:,
  #    db_table: "do_billing",
  #    tag: "FetchBillingFromDigitalOcean",
  #    avoid_process: true,
  #    where: "archived=$1 AND tag=$2 ORDER BY inserted_at DESC",
  #    params: [false, "FetchBillingFromDigitalOcean"]
  #  }
  #
  #  write_options = {
  #    connection:,
  #    db_table: "do_billing",
  #    tag: "FetchBillingFromDigitalOcean"
  #  }
  #
  #  options = {
  #    secret: "digital_ocean_api_token"
  #  }
  #
  #  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  # Implementation::FetchBillingFromDigitalOcean.new(options, shared_storage).execute
  #
  class FetchBillingFromDigitalOcean < Bas::Bot::Base
    # Process function to execute the DigitalOcean utility to fetch bills
    #
    def process
      response = Utils::DigitalOcean::Request.execute(params)

      if response.code == 200
        { success: { billing: response.parsed_response, last_billing: } }
      else
        { error: { message: response.parsed_response, status_code: response.code } }
      end
    end

    private

    def params
      {
        endpoint: 'customers/my/balance',
        secret: process_options[:secret],
        method: 'get',
        body: {}
      }
    end

    def last_billing
      read_response.data['billing'] unless read_response.data.nil?
    end
  end
end
