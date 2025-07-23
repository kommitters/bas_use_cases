# frozen_string_literal: true

require 'date'
require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FetchPtoFromGoogle class filters and formats current-day PTOs
  # from Google Workspace data. It generates human-readable messages and write them
  # on a PostgresDB table with a specific format.
  #
  # <b>Example</b>
  #
  #   options = {
  #     ptos: [
  #       {
  #         "Person" => "Jane Doe",
  #         "StartdateTime" => "2025-07-21",
  #         "EndDateTime" => "2025-07-22"
  #       }
  #     ]
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options: write_options)
  #
  #   Implementation::FetchPtoFromGoogle.new(options, shared_storage_reader, shared_storage_writer).execute
  class FetchPtoFromGoogle < Bas::Bot::Base
    def process
      today = Date.today

      filtered_ptos = process_options[:ptos].map { |pto| symbolize_keys(pto) }.select do |pto|
        start_date = parse_date(pto[:StartDateTime])
        end_date   = parse_date(pto[:EndDateTime])

        (start_date..end_date).cover?(today)
      end

      ptos_list = normalize_response(filtered_ptos)
      { success: { ptos: ptos_list } }
    end

    private

    def normalize_response(ptos)
      ptos.map do |pto|
        name       = pto[:Person]
        start_date = parse_date(pto[:StartDateTime])
        end_date   = parse_date(pto[:EndDateTime])

        description(name, start_date, end_date)
      end
    end

    def parse_date(value)
      Date.iso8601(value.to_s)
    rescue ArgumentError
      DateTime.iso8601(value.to_s).to_date
    end

    def description(name, start_date, end_date)
      start_str = start_date.strftime('%Y-%m-%d')
      end_str   = end_date.strftime('%Y-%m-%d')
      "#{name} will not be working between #{start_str} and #{end_str}. And returns the #{returns(end_date)}"
    end

    def returns(date)
      next_work_day(date)
    end

    def next_work_day(date)
      next_day = case date.wday
                 when 5 then date + 3 # Friday → Monday
                 when 6 then date + 2 # Saturday → Monday
                 else date + 1
                 end

      next_day.strftime('%A %B %d of %Y')
    end

    def symbolize_keys(hash)
      hash.transform_keys do |key|
        key.to_sym
      rescue StandardError
        key
      end
    end
  end
end
