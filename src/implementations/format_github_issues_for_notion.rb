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
    ##
    # Processes GitHub issues data and formats it for insertion into a Notion database.
    #
    # Retrieves GitHub issues from shared storage, validates the data, and returns a hash containing either the formatted issues or an error message if data is missing or an exception occurs.
    #
    # @return [Hash] A hash with either a :success key containing formatted issues or an :error key with an error message.
    def process
      github_issues = read_response.data
      return { error: { message: 'No GitHub issues data found' } } unless github_issues.is_a?(Array)

      { success: format_for_notion(github_issues) }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    ##
    # Formats an array of GitHub issues into Notion-compatible hashes.
    #
    # Each issue is transformed into a hash with title, labels, issue ID, and body content structured for Notion database insertion.
    #
    # @param issues [Array<Hash>] Array of GitHub issue hashes to format
    # @return [Array<Hash>] Array of hashes formatted for Notion
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

    ##
    # Formats a GitHub issue title as a Notion title block.
    #
    # If the title is nil, defaults to "No title specified".
    #
    # @param title [String, nil] The GitHub issue title.
    # @return [Hash] A Notion-compatible title property block.
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

    # @return [Hash] Notion multi-select property with label names, or empty if input is not an array.
    def format_labels(labels)
      return { multi_select: [] } unless labels.is_a?(Array)

      {
        multi_select: labels.map { |label| { name: label['name'] } }
      }
    end

    ##
    # Formats the GitHub issue ID as a Notion rich text block.
    #
    # @param issue_id [Integer, String] The GitHub issue number.
    # @return [Hash] A Notion-compatible rich text block containing the issue ID.
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

    ##
    # Formats the body of a GitHub issue into an array of Notion blocks.
    #
    # Returns an array containing a file block linking to the GitHub issue, a heading block for the issue description, and a paragraph block with the issue body text. Returns an empty array if the issue is nil.
    #
    # @param issue [Hash, nil] The GitHub issue data.
    # @return [Array<Hash>] Array of Notion block hashes representing the issue body.
    def format_body(issue)
      return [] if issue.nil?

      [
        format_issue_link(issue),
        format_body_title,
        format_issue_body(issue['body'])
      ]
    end

    ##
    # Creates a Notion file block linking to the GitHub issue.
    #
    # @param issue [Hash] The GitHub issue data containing 'html_url' and 'number'.
    # @return [Hash] A Notion file block with an external URL to the issue and a descriptive name.
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

    # @return [Hash] Notion block representing the issue description heading
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

    ##
    # Formats the issue body as a Notion paragraph block, stripping whitespace and truncating to 2000 characters.
    #
    # @param issue_body [String] The body text of the GitHub issue.
    # @return [Hash] A Notion-compatible paragraph block containing the issue body.
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
