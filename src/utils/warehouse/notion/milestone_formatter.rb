# frozen_string_literal: true

require_relative 'base'
require 'bas/utils/notion/request'

module Utils
  module Warehouse
    module Notion
      module Formatter
        ##
        # This class formats Notion milestone records into a standardized hash format.
        class MilestoneFormatter < Base
          def initialize(record, external_project_id:)
            super(record)
            @external_project_id = external_project_id
          end

          def format
            {
              external_milestone_id: extract_id,
              name: extract_title('Description'),
              status: extract_checkbox('Completed') ? 'completed' : 'incomplete',
              completion_date: extract_date('Deadline'),
              external_project_id: @external_project_id
            }
          end

          class << self
            def fetch_for_projects(raw_project_records, secret:, filter_body: {})
              raw_project_records.flat_map do |project_record|
                project_id = project_record['id']
                db_id = find_milestone_database_id(project_id, secret: secret)
                next [] unless db_id

                records = fetch_milestone_records(db_id, secret: secret, filter_body: filter_body)
                next [] if records.empty?

                format_records(records, project_id: project_id)
              end
            end

            private

            def find_milestone_database_id(project_id, secret:)
              response = notion_request(endpoint: "blocks/#{project_id}/children", method: 'get', secret: secret)
              return nil unless response.code == 200

              db_block = response.parsed_response['results'].find { |block| block['type'] == 'child_database' }
              db_block ? db_block['id'] : nil
            end

            def fetch_milestone_records(database_id, secret:, filter_body: {})
              response = notion_request(endpoint: "databases/#{database_id}/query", secret: secret, body: filter_body)
              return [] unless response.code == 200

              response.parsed_response['results']
            end

            def format_records(records, project_id:)
              records.map do |record|
                new(record, external_project_id: project_id).format
              end
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
