# frozen_string_literal: true

module Utils
  module Logger
    ##
    # ErrorSanitizer Class
    #
    # This module provides functionality to sanitize error messages
    # before logging them, especially when they exceed a certain size.
    #
    class ErrorSanitizer
      HTML_HINT   = /<!doctype html|<html|<body/i
      HTTP_ERRORS = /(401|403|404|500).*?(unauthorized|forbidden|not found|internal server error)|ora-\d+/i
      MAX_LENGTH  = 512

      def self.sanitize(obj, original_size)
        return obj unless obj.is_a?(Hash)

        sanitize_field(obj, 'error', original_size)

        sanitize_field(obj['context'], 'error', original_size) if obj['context'].is_a?(Hash)

        obj
      end

      class << self
        private

        def sanitize_field(container, key, original_size)
          value = container[key]
          return unless value.is_a?(String)

          if value =~ HTML_HINT
            container[key] = html_message(value, original_size)
          elsif value.length > MAX_LENGTH
            container[key] = truncated_message(value, original_size)
          end
        end

        def html_message(text, original_size)
          if text =~ HTTP_ERRORS
            "Remote HTTP error (HTML #{original_size} bytes, body omitted to prevent log inflation)."
          else
            "HTML response of #{original_size} bytes omitted to prevent log inflation."
          end
        end

        def truncated_message(text, original_size)
          snippet = text[0, MAX_LENGTH]
          "Very long error (#{original_size} bytes). Start (#{MAX_LENGTH} chars): #{snippet.inspect}"
        end
      end
    end
  end
end
