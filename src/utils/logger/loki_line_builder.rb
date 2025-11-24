# frozen_string_literal: true

require_relative 'error_sanitizer'

module Utils
  module Logger
    ##
    # LokiLineBuilder Module
    # This module provides functionality to build log lines
    # suitable for sending to Grafana Loki, ensuring they
    # do not exceed a specified byte size limit.
    #
    class LokiLineBuilder
      MAX_BYTES = 900_000

      def self.build(serialized, max_bytes = MAX_BYTES) # rubocop:disable Metrics/MethodLength
        return '' if serialized.nil? || serialized.empty?

        obj = begin
          JSON.parse(serialized)
        rescue StandardError
          nil
        end

        return trim(serialized, max_bytes) unless obj.is_a?(Hash)

        original_size = serialized.bytesize
        sanitized = ErrorSanitizer.sanitize(obj, original_size)
        json = JSON.generate(sanitized)
        trim(json, max_bytes)
      end

      class << self
        private

        def trim(str, max_bytes)
          return str if str.bytesize <= max_bytes

          allowed = [max_bytes - 3, 0].max
          "#{str.byteslice(0, allowed)}..."
        end
      end
    end
  end
end
