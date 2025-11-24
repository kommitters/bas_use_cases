# frozen_string_literal: true

require 'bas/bot/base'

module Implementation
  class FormatGithubIssuesForApex < Bas::Bot::Base
    DEFAULT_STATUS = 'BACKLOG'
    DEFAULT_DESCRIPTION = 'No description provided'

    def process
      row = read_response
      return nil if row.nil? || row.data.nil?

      source_data = row.data
      return nil if summary_row?(source_data)

      issue     = extract_issue(source_data)
      formatted = build_payload(issue, source_data)

      # ===========================================
      # *** FORMATO CORRECTO ***
      #
      # SharedStorage recibirá:
      #   data = formatted
      #   stage = processed
      # ===========================================
      {
        success: formatted,
        stage:   "processed"
      }

    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    def summary_row?(data)
      data.is_a?(Hash) && (data["created"] == true || data[:created] == true)
    end

    def extract_issue(data)
      return data['issue'] if data['issue'].is_a?(Hash)

      { "title" => data["title"], "body" => data["body"] }
    end

    def build_payload(issue, source_data)
      {
        "name"        => (issue['title'] || 'Untitled issue'),
        "description" => description_value(issue, source_data),
        "status"      => status_value(source_data),
        "deadline"    => deadline_value(source_data)
      }
    end

    def status_value(source_data)
      source_data['status'] ||
        process_options[:default_status] ||
        DEFAULT_STATUS
    end

    def deadline_value(source_data)
      source_data['deadline'] ||
        process_options[:default_deadline]
    end

    def description_value(issue, source_data)
      body = issue['body']
      return body unless body.nil? || body.strip.empty?

      source_data['description'] ||
        process_options[:default_description] ||
        DEFAULT_DESCRIPTION
    end
  end
end
