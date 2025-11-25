# frozen_string_literal: true

require 'date'

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

    case next_day.wday
    when 6 # sat
      next_day += 2
    when 0 # sun
      next_day += 1
    end

    format_date(next_day)
  end

  # logic to format a PTO entry into a message
  def format_message(entry)
    name  = entry['person'] || entry['Person'] || 'Someone'

    start = to_date_only(entry['start_datetime'] || entry['StartDateTime'])
    end_d = to_date_only(entry['end_datetime']   || entry['EndDateTime'])

    start_s = format_date(start)
    end_s   = format_date(end_d)
    ret_s   = next_workday(end_d)

    "#{name} will not be working between #{start_s} and #{end_s}. And returns the #{ret_s}"
  end

  # Todays PTOs
  def filter_today(ptos)
    today = Date.today
    return [] if today.saturday? || today.sunday?

    ptos.select do |entry|
      start_date = to_date_only(entry['start_datetime'] || entry['StartDateTime'])
      end_date   = to_date_only(entry['end_datetime']   || entry['EndDateTime'])
      next if start_date.nil? || end_date.nil?

      in_range = start_date <= today && today <= end_date
      is_pto   = entry['category'].to_s.include?('PTO') ||
                 entry['Category'].to_s.include?('PTO')

      full_day = entry['day'].to_s == 'Full Day' ||
                 entry['Day'].to_s == 'Full Day'

      in_range && is_pto && full_day
    end
  end

  # Build payload for TODAY PTOs:
  def build_payload_today(ptos)
    filtered  = filter_today(ptos)
    messages  = filtered.map { |e| format_message(e) }

    { 'ptos' => messages }
  end
end
