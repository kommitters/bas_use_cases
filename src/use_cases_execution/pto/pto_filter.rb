# frozen_string_literal: true

require 'date'

# PTO filtering and formatting utilities for daily notifications.
module PtoFilter
  module_function

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
    next_day += 2 if next_day.saturday?
    next_day += 1 if next_day.sunday?

    format_date(next_day)
  end

  def format_message(entry)
    name  = entry['person'] || entry['Person'] || 'Someone'

    start = to_date_only(entry['start_datetime'] || entry['StartDateTime'])
    end_d = to_date_only(entry['end_datetime']   || entry['EndDateTime'])

    start_s = format_date(start)
    end_s   = format_date(end_d)
    ret_s   = next_workday(end_d)

    "#{name} will not be working between #{start_s} and #{end_s}. And returns the #{ret_s}"
  end

  # --------------------------------------------------------------------
  # Helpers extracted to satisfy RuboCop complexity rules
  # --------------------------------------------------------------------

  def weekend?(date)
    date.saturday? || date.sunday?
  end

  def extract_start(entry)
    to_date_only(entry['start_datetime'] || entry['StartDateTime'])
  end

  def extract_end(entry)
    to_date_only(entry['end_datetime'] || entry['EndDateTime'])
  end

  def pto_category?(entry)
    entry['category'].to_s.include?('PTO') ||
      entry['Category'].to_s.include?('PTO')
  end

  def full_day?(entry)
    entry['day'].to_s == 'Full Day' ||
      entry['Day'].to_s == 'Full Day'
  end

  def active_today?(today, start_date, end_date)
    start_date <= today && today <= end_date
  end

  def valid_pto_today?(entry, today)
    start_date = extract_start(entry)
    end_date   = extract_end(entry)
    return false if start_date.nil? || end_date.nil?

    active_today?(today, start_date, end_date) &&
      pto_category?(entry) &&
      full_day?(entry)
  end

  # --------------------------------------------------------------------
  # FINAL VERSION: passes ALL RuboCop metrics
  # --------------------------------------------------------------------
  def filter_today(ptos)
    today = Date.today
    return [] if weekend?(today)

    ptos.select { |entry| valid_pto_today?(entry, today) }
  end

  def build_payload_today(ptos)
    { 'ptos' => filter_today(ptos).map { |e| format_message(e) } }
  end
end
