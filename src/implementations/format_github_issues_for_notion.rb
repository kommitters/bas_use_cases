# frozen_string_literal: true

require 'bas/bot/base'

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
  #     db_table: "github_issues",
  #     where: "stage='unprocessed' AND tag=$1 ORDER BY inserted_at DESC",
  #     params: ['GithubIssueRequest']
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: "github_issues",
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
      data = read_response.data
      return { error: { message: 'No GitHub issue data found' } } unless data.is_a?(Hash)
      return { error: { message: 'Empty issue hash received' } } if data.empty?
      return { error: { message: 'Missing issue payload' } } unless data.key?('issue') && data['issue'].is_a?(Hash)

      { success: format_for_notion(data['issue']) }
    rescue StandardError => e
      { error: { message: e.message } }
    end

    private

    def format_for_notion(issue)
      {
        issue_number: issue['number'],
        issue_id: issue['id'],
        notion_object: {
          'Detail' => format_title(issue['title']),
          'Tags' => format_labels(issue['labels']),
          process_options[:notion_property] => format_issue_id(issue['number']),
          'children' => format_body(issue)
        }
      }
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

      [format_issue_link(issue)]
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
  end
end
