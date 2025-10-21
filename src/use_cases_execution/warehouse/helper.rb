# frozen_string_literal: true

require 'date'

module Warehouse
  ##
  # Encapsulates Warehouse helper functions.
  module Helper
    def self.get_last_execution_date(shared_storage)
      last_record = shared_storage.read
      return unless last_record&.inserted_at

      # Always retrieve date as "20XX-XX-XXTXX:XX:XX.XXX-0000" since using "+" causes issues in some endpoints.
      DateTime.parse(last_record.inserted_at).strftime('%Y-%m-%dT%H:%M:%S.%L%z').sub('+', '-')
    end
  end
end
