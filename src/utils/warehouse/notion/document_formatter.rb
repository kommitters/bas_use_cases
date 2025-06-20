# frozen_string_literal: true

require_relative 'base'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion document records into a standardized hash format.
        class DocumentFormatter < Base
          def format
            {
              external_document_id: extract_id,
              name: extract_title('Name'),
              external_domain_id: extract_relation('Domain').first
            }
          end
        end
      end
    end
  end
end
