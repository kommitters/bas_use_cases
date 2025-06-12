# frozen_string_literal: true

require 'date'

module Utils
  module Warehouse
    module Notion
      ##
      # Base class for Notion data extraction.
      # This class provides methods to extract various types of data from Notion records,
      # such as rich text, select, multi-select, relation, and title.
      class Base
        def initialize(notion_data)
          @data = notion_data
          @properties = @data['properties']
        end

        def extract_rich_text(column_name)
          value = @properties[column_name]
          return '' unless value && value['rich_text'] && !value['rich_text'].empty?

          value['rich_text'].map { |rt| rt['plain_text'] }.join(' ')
        end

        def extract_select(column_name)
          value = @properties[column_name]
          return '' if value.nil? || value['select'].nil?

          value['select']['name']
        end

        def extract_status(column_name)
          value = @properties[column_name]
          return '' if value.nil? || value['status'].nil?

          value['status']['name']
        end

        def extract_date(column_name)
          value = @properties[column_name]
          return nil if value.nil? || value['date'].nil?

          date_value = value['date']['start']
          return nil if date_value.nil? || date_value.empty?

          Date.parse(date_value)
        end

        def extract_multi_select(column_name)
          value = @properties[column_name]
          return [] if value.nil? || value['multi_select'].nil?

          value['multi_select'].map { |v| v['name'] }
        end

        def extract_relation(column_name)
          value = @properties[column_name]
          return [] if value.nil? || value['relation'].nil?

          value['relation'].map { |rel| rel['id'] }
        end

        def extract_title(column_name)
          value = @properties[column_name]
          return '' unless value && value['title'] && !value['title'].empty?

          value['title'].map { |t| t['plain_text'] }.join(' ')
        end

        def extract_id
          @data['id']
        end
      end
    end
  end
end
