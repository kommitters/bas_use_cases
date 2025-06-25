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

        def extract_number(column_name)
          value = @properties[column_name]
          return nil if value.nil? || value['number'].nil?

          value['number']
        end

        def extract_email(column_name)
          value = @properties[column_name]
          return nil if value.nil? || value['email'].nil?

          value['email']
        end

        def extract_people_id(column_name)
          value = @properties[column_name]
          return nil if value.nil? || value['people'].nil? || value['people'].empty?

          value['people'].first['id']
        end

        def extract_formula_number(column_name)
          value = @properties[column_name]
          return nil if value.nil? || value['formula'].nil?
          return nil unless value['formula']['type'] == 'number'

          value['formula']['number']
        end

        def extract_rollup_value(column_name) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
          value = @properties[column_name]
          return '' unless value && value['rollup'] && value['rollup']['array'].is_a?(Array)

          value['rollup']['array'].map do |item|
            case item['type']
            when 'title'
              item['title']&.map { |t| t['plain_text'] }&.join(' ')
            when 'select'
              item['select']&.dig('name')
            end
          end.compact.join(' ')
        end
      end
    end
  end
end
