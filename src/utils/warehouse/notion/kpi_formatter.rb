# frozen_string_literal: true

require_relative 'base'
require 'bas/utils/notion/request'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion KPI records into a standardized hash format.
        # It also fetches nested stats from a child database within each KPI page.
        class KpiFormatter < Base
          def format
            {
              external_kpi_id: extract_id,
              description: extract_rich_text('Description'),
              status: extract_select('Status'),
              current_value: extract_number('Current Value'),
              percentage: extract_formula_number('Percentage'),
              target_value: extract_number('Target Value'),
              external_domain_id: extract_relation('Domain')
            }
          end

          class << self
            ##
            # Fetches and formats KPIs from Notion, including their stats.
            # It retrieves the stats from a child database linked to each KPI page.
            def fetch_stats_for_kpis(records, secret:, filter_body: {})
              records.map do |kpi_record|
                formatted_kpi = new(kpi_record).format

                kpi_page_id = kpi_record['id']
                stats_db_id = find_stats_database_id(kpi_page_id, secret: secret)

                format_stats = fetch_and_format_stats_dynamically(stats_db_id, secret: secret, filter_body: filter_body)
                stats = stats_db_id ? format_stats : []

                formatted_kpi.merge(stats: stats.to_json)
              end
            end

            private

            STATS_PROPERTY_EXTRACTORS = {
              'title' => ->(data) { data.first&.dig('plain_text') },
              'rich_text' => ->(data) { data.first&.dig('plain_text') },
              'number' => ->(data) { data },
              'formula' => lambda do |data|
                data['number'] if data['type'] == 'number'
              end
            }.freeze

            def find_stats_database_id(kpi_page_id, secret:)
              top_level_blocks = fetch_child_blocks(kpi_page_id, secret: secret)
              return nil unless top_level_blocks

              year_block = find_year_block(top_level_blocks)
              return nil unless year_block

              year_block_children = fetch_child_blocks(year_block['id'], secret: secret)
              return nil unless year_block_children

              db_block = find_database_in_blocks(year_block_children)
              db_block&.dig('id')
            end

            ##
            # Fetches child blocks for a given block ID.
            def fetch_child_blocks(block_id, secret:)
              response = notion_request(endpoint: "blocks/#{block_id}/children", method: 'get', secret: secret)
              response.code == 200 ? response.parsed_response['results'] : nil
            end

            ##
            # Finds the year block (Heading 1 with a 4-digit number) in a list of blocks.
            def find_year_block(blocks)
              blocks.find do |block|
                block['type'] == 'heading_1' && block.dig('heading_1', 'rich_text', 0, 'plain_text')&.match?(/\d{4}/)
              end
            end

            ##
            # Finds the child database block in a list of blocks.
            def find_database_in_blocks(blocks)
              blocks.find { |block| block['type'] == 'child_database' }
            end

            ##
            # Fetches and formats stats dynamically based on the database ID.|
            def fetch_and_format_stats_dynamically(database_id, secret:, filter_body: {})
              response = notion_request(endpoint: "databases/#{database_id}/query", secret: secret, body: filter_body)
              return [] unless response.code == 200

              response.parsed_response['results'].map do |stat_record|
                properties_hash = {}
                stat_record['properties'].each do |prop_name, prop_data|
                  properties_hash[prop_name] = extract_stat_value(prop_data)
                end
                properties_hash
              end
            end

            ##
            # Extracts a specific value from a property data structure.
            # This method is used to handle different property types dynamically.
            def extract_stat_value(prop_data)
              return nil unless prop_data

              type = prop_data['type']
              value_key = prop_data[type]
              return nil if value_key.nil?

              extractor = STATS_PROPERTY_EXTRACTORS.fetch(type, ->(_) { 'unsupported_type' })
              extractor.call(value_key)
            end

            def notion_request(endpoint:, secret:, method: 'post', body: {})
              Utils::Notion::Request.execute(
                endpoint: endpoint,
                secret: secret,
                method: method,
                body: body
              )
            end
          end
        end
      end
    end
  end
end
