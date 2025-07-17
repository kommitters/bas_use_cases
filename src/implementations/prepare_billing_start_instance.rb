# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/operaton/process_client'
require 'json'
require 'date'
require 'logger'

module Implementation
  ##
  # The Implementation::PrepareBillingStartInstance class serves as a bot implementation
  # to fetch contracts available for billing and save them in a postgres db
  #
  # <br>
  # <b>Example</b>
  #
  #   write_options = {
  #     connection:,
  #     db_table: "operaton_instances",
  #     tag: "PrepareStartInstance"
  #   }
  #
  #   options = {
  #     operaton_base_url: 'operaton base url',
  #     process_key: 'billing process key',
  #     operaton_api_user: "operaton api user",
  #     operaton_password: "operaton password"
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #   Implementation::PrepareBillingStartInstance.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class PrepareBillingStartInstance < Bas::Bot::Base
    CONTRACTS_PATH = File.expand_path('../use_cases_execution/operaton_billing_process/contracts.json', __dir__)

    def process
      contracts = contracts_enabled
      return { success: { contracts: [] } } if contracts.empty?

      { success: { contracts: contracts } }
    end

    def write
      contracts = process_response.dig(:success, :contracts) || []
      return if contracts.empty?

      contracts.each do |contract|
        record_to_write = format_billing_data_instance(contract)
        @shared_storage_writer.write({ success: record_to_write })
      end
    end

    def test
      client = build_client
      puts client.test_engine
    end

    private

    def contracts_enabled
      today = Date.today
      contracts_to_bill = read_contracts_from_json.select { |c| billing_due?(c, today) }

      return [] if contracts_to_bill.empty?

      contracts_to_start = filter_contracts_to_start(contracts_to_bill)

      return [] if contracts_to_start.empty?

      contracts_to_start
    end

    def filter_contracts_to_start(contracts)
      client = build_client
      contracts.reject do |contract|
        validate_business_key(client, process_options[:process_key], contract[:contract_id])
      end
    end

    def read_contracts_from_json
      file = File.read(CONTRACTS_PATH)
      JSON.parse(file, symbolize_names: true)
    rescue StandardError => e
      error_message(e.message, 'A problem occurred trying to read json')
    end

    def billing_due?(contract, today)
      return false unless billing_applicable?(contract)

      last_billed = parse_last_billed_date(contract)
      return false unless last_billed

      next_billing = calculate_next_billing(contract, last_billed)
      return false unless next_billing

      today >= next_billing
    end

    def billing_applicable?(contract)
      contract[:active] && contract[:billing_frequency]
    end

    def parse_last_billed_date(contract)
      last_billed_str = contract[:last_billed_date] || contract[:start_date]
      return nil unless last_billed_str

      Date.parse(last_billed_str)
    rescue ArgumentError
      info_message("Invalid date format for contract #{contract[:contract_id]}")
      nil
    end

    def calculate_next_billing(contract, last_billed)
      case contract[:billing_frequency]
      when 'weekly' then last_billed + 7
      when 'monthly' then last_billed >> 1
      when 'quarterly' then last_billed >> 3
      when 'annually' then last_billed >> 12
      else
        info_message("Unknown billing_frequency: #{contract[:billing_frequency]} for #{contract[:contract_id]}")
        nil
      end
    end

    def validate_business_key(client, process_key, business_key)
      client.instance_with_business_key_exists?(process_key, business_key)
    rescue StandardError => e
      error_message(e.message, 'Problem with business key validation')
    end

    def build_client
      Utils::Operaton::ProcessClient.new(
        base_url: process_options[:operaton_base_url], username: process_options[:operaton_api_user],
        password: process_options[:operaton_password]
      )
    end

    def format_billing_data_instance(contract)
      {
        variables: billing_variables(contract),
        process_key: process_options[:process_key],
        business_key: contract[:contract_id]
      }
    end

    def billing_variables(contract)
      {
        contractId: contract[:contract_id], clientId: contract[:client_id],
        clientName: contract[:client_name], billingDate: Date.today.to_s,
        fixedPrice: contract[:fixed_price], fixedRate: contract[:fixed_rate],
        rateUnit: contract[:rate_unit], paymentDueDays: contract.dig(:terms, :payment_due_days),
        gracePeriodDays: contract.dig(:terms, :grace_period_days)
      }
    end

    def error_message(error, message)
      Logger.new($stdout).error("#{message}: #{error}")
      { error: error }
    end

    def info_message(message)
      Logger.new($stdout).info(message)
      { success: message }
    end
  end
end
