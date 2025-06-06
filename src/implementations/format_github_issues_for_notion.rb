# frozen_string_literal: true

require 'bas/bot/base'
require 'byebug'

module Implementation
  ##
  # The Implementation::FormatGithubIssuesForNotion class serves as a bot implementation to format GitHub issues
  # data for Notion database insertion.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_notion_issues_sync",
  #     tag: 'FetchGithubIssues',
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_notion_issues_sync",
  #     tag: 'FormatGithubIssues'
  #   }
  #
  #   options = {}
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FormatGithubIssuesForNotion.new(options, shared_storage).execute
  #
  class FormatGithubIssuesForNotion < Bas::Bot::Base
    def process
      github_issues = read_response.data
      return { error: { message: 'No GitHub issues data found' } } unless github_issues.is_a?(Array)

      { success: format_for_notion(github_issues) }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    def format_for_notion(issues)
      issues.map do |issue|
        {
          'Detail' => format_title(issue['title']),
          'Tags' => format_labels(issue['labels']),
          'Github issue id' => format_issue_id(issue['number']),
          'children' => format_body(issue)
        }
      end
    end

    def format_title(title)
      {
        type: 'title',
        title: [
          {
            type: 'text',
            text: { content: title || 'No title specified' }
          }
        ]
      }
    end

    def format_labels(labels)
      return { multi_select: [] } unless labels.is_a?(Array)

      {
        multi_select: labels.map { |label| { name: label['name'] } }
      }
    end

    def format_issue_id(issue_id)
      {
        rich_text: [
          {
            type: 'text',
            text: {
              content: issue_id.to_s
            }
          }
        ]
      }
    end

    def format_body(issue)
      return [] if issue.nil?

      [
        format_issue_link(issue),
        format_body_title,
        format_issue_body(issue['body'])
      ]
    end

    def format_issue_link(issue)
      {
        object: 'block',
        type: 'file',
        file: {
          type: 'external',
          external: { url: issue['html_url'] },
          name: "Check issue ##{issue['number']} on Github"
        }
      }
    end

    def format_body_title
      {
        type: 'heading_1',
        heading_1: { # rubocop:disable Naming/VariableNumber
          rich_text: [{
            type: 'text',
            text: { content: 'Issue description' }
          }]
        }
      }
    end

    def format_issue_body(issue_body)
      {
        object: 'block',
        type: 'paragraph',
        paragraph: {
          rich_text: [
            { type: 'text', text: { content: issue_body.strip[0..1999] } }
          ]
        }
      }
    end
  end
end
