# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion database records into a standardized hash format.
        class DatabaseFormatter < Base
          def format
            {
              external_database_id: extract_id,
              name: extract_title('Name')
            }
          end
        end
      end
    end
  end
end
