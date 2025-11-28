# frozen_string_literal: true

require 'json'
require 'date'
require 'logger'

require 'bas/bot/base'
require_relative '../utils/apex/apex_get_general'

module Implementation
  ##
  # The Implementation::FetchPtosFromApex class serves as a bot implementation to read PTOs
  # from an APEX REST endpoint and write them on a PostgresDB table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   options = {
  #     apex_endpoint: "taskman_pto"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "pto",
  #     tag: "FetchPtosFromApex"
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #   Implementation::FetchPtosFromApex
  #     .new(options, shared_storage_reader, shared_storage_writer)
  #     .execute
  #
  class FetchPtosFromApex < Bas::Bot::Base
    # Process function to execute the APEX utility to fetch PTO's from the APEX endpoint
    def process
      response = fetch_ptos
      Logger.new($stdout).info("[FetchPtosFromApex] HTTP #{response.code}")
      return handle_success(response) if response.code == 200
      handle_failure(response)
    rescue StandardError => e
      log_unexpected_error(e)
      { error: { message: e.message } }
    end

    private

    def fetch_ptos
      ApexClient.get(endpoint: process_options[:apex_endpoint])
    end

    def handle_success(response)
      items = parse_items(response.body)
      ptos  = normalize_response(items)
      { success: { ptos: ptos } }
    end

    def handle_failure(response)
      Logger.new($stdout).error("[FetchPtosFromApex] Failed with status #{response.code}")
      { error: { status_code: response.code, body: response.body.to_s } }
    end

    def log_unexpected_error(error)
      Logger.new($stdout).error("[FetchPtosFromApex] Unexpected error: #{error.message}")
    end

    def parse_items(body)
      json = JSON.parse(body)
      json['items'] || []
    end

    def normalize_response(items)
      today = Date.today
      return [] if weekend?(today)

      todays = items.select { |entry| valid_pto_today?(entry, today) }
      todays.map { |entry| build_message(entry) }
    end

    def valid_pto_today?(entry, today)
      start_date = extract_start(entry)
      end_date   = extract_end(entry)
      return false if start_date.nil? || end_date.nil?

      active_today?(today, start_date, end_date) &&
        pto_category?(entry) &&
        full_day?(entry)
    end

    def active_today?(today, start_date, end_date)
      start_date <= today && today <= end_date
    end

    def weekend?(date)
      date.saturday? || date.sunday?
    end

    def pto_category?(entry)
      entry['category'].to_s.include?('PTO') ||
        entry['Category'].to_s.include?('PTO')
    end

    def full_day?(entry)
      entry['day'].to_s == 'Full Day' ||
        entry['Day'].to_s == 'Full Day'
    end

    def build_message(entry)
      name  = extract_name(entry)
      start = extract_start(entry)
      finish = extract_end(entry)

      start_s = format_date(start)
      finish_s = format_date(finish)
      return_s = next_workday(finish)

      "#{name} will not be working between #{start_s} and #{finish_s}. And returns on #{return_s}"
    end

    def extract_name(entry)
      entry['person'] ||
        entry['Person'] ||
        entry['Employee'] ||
        'Someone'
    end

    def extract_start(entry)
      to_date_only(entry['start_datetime'] || entry['StartDateTime'])
    end

    def extract_end(entry)
      to_date_only(entry['end_datetime'] || entry['EndDateTime'])
    end

    def to_date_only(value)
      Date.parse(value.to_s)
    rescue StandardError
      nil
    end

    def format_date(date)
      date&.strftime('%Y-%m-%d')
    end

    def next_workday(date)
      return nil if date.nil?

      next_day = date + 1
      next_day += 1 while weekend?(next_day)
      next_day.strftime('%Y-%m-%d')
    end
  end
end
