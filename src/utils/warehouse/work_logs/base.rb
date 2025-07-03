# frozen_string_literal: true

module Utils
  module Warehouse
    module WorkLogs
      ##
      # Base class for work log utilities.
      # This class provides methods to handle work log data, such as extracting and formatting.
      class Base
        def initialize(work_log_record)
          @record = work_log_record
        end

        def format_tags(tags)
          tags ? "{#{tags.join(',')}}" : nil
        end
      end
    end
  end
end
