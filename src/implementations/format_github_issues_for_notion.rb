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

      formatted_issues = format_for_notion(github_issues)
      { success: formatted_issues }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    def format_for_notion(issues)
      issues.map do |issue|
        {
          'Name': format_title(issue['title']),
          'Tags' => format_labels(issue['labels']),
          'children' => format_body(issue),
          'Github issue id' => issue['number']
        }
      end
    end

    def format_title(title)
      {
        title: [
          {
            text: {
              content: title || 'No title specified'
            }
          }
        ]
      }
    end

    def format_labels(labels)
      return { type: 'multi_select', multi_select: [] } unless labels.is_a?(Array)

      {
        type: 'multi_select', multi_select: labels.map { |label| { name: label['name'] } }
      }
    end

    def format_body(issue)
      return [] if issue.nil?

      [
        {
          type: 'link_preview',
          link_preview: {
            url: issue['html_url']
          }
        },
        {
          object: 'block',
          type: 'paragraph',
          paragraph: {
            rich_text: [
              { type: 'text', text: { content: issue['body'].strip } }
            ]
          }
        }
      ]
    end
  end
end
