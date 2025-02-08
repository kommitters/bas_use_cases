# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/utils/notion/request'
require 'bas/utils/notion/types'
require 'logger'

module Implementation
  ##
  # The Implementation::CreateWorkItem class serves as a bot implementation to create "work items" on a
  # notion database using information of a GitHub issue.
  #
  # <br>
  # <b>Example</b>
  #
  #  read_options = {
  #    connection:,
  #    db_table: "github_issues",
  #    tag: "CreateWorkItemRequest"
  #  }
  #
  #  write_options = {
  #    connection:,
  #    db_table: "github_issues",
  #    tag: "CreateWorkItem"
  #  }
  #
  #  options = {
  #    database_id: "notion_database_id",
  #    secret: "notion_secret"
  #  }
  #
  #  shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  # Implementation::CreateWorkItem.new(options, shared_storage).execute
  #
  class CreateWorkItem < Bas::Bot::Base
    include Utils::Notion::Types

    UPDATE_REQUEST = 'UpdateWorkItemRequest'
    STATUS = 'Backlog'
    LOGGER = Logger.new($stdout)

    # process function to execute the Notion utility to create work items on a notion
    # database
    #
    def process
      return { success: { created: nil } } if unprocessable_response?

      data = read_response.data || {}
      issues = Array(data['issues'] || [data['issue']].compact)
      LOGGER.info("Total issues received: #{issues.size}")

      results = issues.map { |issue| process_issue(issue) }
      { success: { issues: results } }
    rescue StandardError => e
      LOGGER.error("An unexpected error occurred: #{e.message}")
      { error: { message: e.message, backtrace: e.backtrace } }
    end

    def write
      @shared_storage_writer.write_options = @shared_storage_writer.write_options.merge({ tag: })
      @shared_storage_writer.write(process_response)
    end

    private

    def process_issue(issue)
      response = Utils::Notion::Request.execute(params(issue))

      if response.code == 200
        { issue: issue, notion_wi: response['id'] }
      else
        { issue: issue, error: { message: response.parsed_response, status_code: response.code } }
      end
    ensure
      sleep(2)
    end

    def unprocessable_response?
      read_response.data.nil?
    end

    def params(issue)
      {
        endpoint: 'pages',
        secret: process_options[:secret],
        method: 'post',
        body: body(issue)
      }
    end

    def body(issue)
      {
        parent: { database_id: process_options[:database_id] },
        properties: properties(issue),
        children: clean_body(issue)
      }
    end

    def properties(issue)
      {
        "Responsible domain": responsible_domain(issue),
        "Github Issue Id": github_issue_id(issue),
        "Status": status,
        "Detail": detail(issue)
      }.merge(work_item_type(issue))
    end

    def work_item_type(issue)
      case issue['work_item_type']
      when 'activity' then { "Activity": relation(issue['type_id']) }
      when 'project' then { "Project": relation(issue['type_id']) }
      else {}
      end
    end

    def responsible_domain(issue)
      { select: { name: issue['domain'] || 'kommit.engineering' } }
    end

    def github_issue_id(issue)
      { rich_text: [{ text: { content: issue['id'].to_s } }] }
    end

    def status
      { status: { name: STATUS } }
    end

    def detail(issue)
      { title: [{ text: { content: clean_title(issue) } }] }
    end

    def clean_title(issue)
      issue['title'].to_s.gsub(/#+\s*/, '').strip
    end

    def clean_body(issue)
      return [] unless issue['body']

      text = clean_text(issue['body'])
      [{ type: 'paragraph', paragraph: { rich_text: [{ type: 'text', text: { content: text } }] } }]
    end

    def clean_text(text)
      text.gsub(/^#+\s*|\n#+\s*/, '')
          .gsub(/\*\*(.*?)\*\*|_(.*?)_|`(.*?)`/, '\1\2\3')
          .gsub(/```.*?```/m, '')
          .gsub(/^>\s*/, '')
          .gsub(/\n{3,}/, "\n\n")
          .strip
    end

    def tag
      if process_response[:success].nil? || process_response[:success][:notion_wi].nil?
        return @shared_storage_writer.write_options[:tag]
      end

      UPDATE_REQUEST
    end
  end
end
