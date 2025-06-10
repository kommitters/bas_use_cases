# frozen_string_literal: true

require_relative 'base'

module Formatter
  ##
  # This class formats Notion activity records into a standardized hash format.
  class ActivityFormatter
    def format(notion_record)
      base = Utils::Warehouse::Notion::Base.new(notion_record)
      {
        external_activity_id: base.extract_id,
        name: base.extract_title('Name'),
        external_domain_id: base.extract_relation('Domain').first
      }
    end
  end
end
