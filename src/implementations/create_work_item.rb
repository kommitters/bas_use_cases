# frozen_string_literal: true

require 'json'
require 'bas/bot/base'
require 'bas/utils/notion/request'
require 'bas/utils/notion/types'
require 'logger'
require 'md_to_notion'
require 'uri'
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
  class CreateWorkItem < Bas::Bot::Base # rubocop:disable Metrics/ClassLength
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
      LOGGER.debug("Processing issue: #{issue.inspect}")
      response = Utils::Notion::Request.execute(params(issue))
      LOGGER.debug("Notion API response: #{response.code} - #{response.parsed_response.inspect}")
      if response.code == 200
        { issue: issue, notion_wi: response['id'] }
      else
        { issue: issue, error: { message: response.parsed_response, status_code: response.code } }
      end
    ensure
      sleep(2)
    end

    def unprocessable_response?
      result = read_response.data.nil?
      LOGGER.debug("Unprocessable response? #{result}")
      result
    end

    def params(issue)
      payload = {
        endpoint: 'pages',
        secret: process_options[:secret],
        method: 'post',
        body: body(issue)
      }
      LOGGER.debug("Payload sent to Notion: #{payload.inspect}")
      payload
    end

    def body(issue)
      {
        parent: { database_id: process_options[:database_id] },
        properties: properties(issue),
        children: format_to_notion_markdown(issue)
      }
    end

    def properties(issue)
      {
        "Activity": activity(issue),
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

    def activity(issue)
      { select: { name: issue['activity'] || 'BAS Maintenance' } }
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

    def format_to_notion_markdown(issue)
      return [] unless issue['body']

      static_blocks = build_static_blocks
      notion_blocks = convert_markdown_to_notion_blocks(issue['body'])
      handle_encodings(notion_blocks)
      context_callout = build_context_callout
      notion_blocks.unshift(context_callout)
      remove_invalid_images(notion_blocks, issue['body'])
      map_code_languages(notion_blocks)
      add_image_urls(notion_blocks, issue['body'])

      [build_column_list_block(build_columns(static_blocks, notion_blocks))]
    end

    def build_static_blocks
      [{
        type: 'callout',
        callout: {
          rich_text: [{ type: 'text', text: { content: '-- To do' } }],
          icon: { emoji: '✅' },
          color: 'blue_background'
        }
      },
       build_to_do_block('Verifiable result 1'),
       build_to_do_block('Verifiable result 2')]
    end

    def build_to_do_block(content)
      {
        type: 'to_do',
        to_do: {
          rich_text: [{ type: 'text', text: { content: content } }],
          checked: false
        }
      }
    end

    def convert_markdown_to_notion_blocks(markdown)
      MdToNotion::Parser.markdown_to_notion_blocks(markdown.to_s)
    end

    def handle_encodings(notion_blocks)
      notion_blocks.each do |block|
        next unless block_paragraph_with_rich_text?(block)

        block[:paragraph][:rich_text].each do |text|
          handle_encoding_for_text(text)
        end
      end
    end

    def block_paragraph_with_rich_text?(block)
      block[:type] == 'paragraph' && block.dig(:paragraph, :rich_text)&.any?
    end

    def handle_encoding_for_text(text)
      return unless text[:text][:content].start_with?('#### ')

      text[:text][:content] = text[:text][:content].sub('#### ', '**')
      text[:annotations] ||= {}
      text[:annotations][:bold] = true
    end

    def build_context_callout
      {
        type: 'callout',
        callout: {
          rich_text: [{ type: 'text', text: { content: '💡 — Context & Description' } }],
          icon: { emoji: 'ℹ️' },
          color: 'blue_background'
        }
      }
    end

    def remove_invalid_images(notion_blocks, _markdown)
      notion_blocks.reject! do |block|
        next unless block_image_with_url?(block)

        image_url = block.dig(:image, :external, :url)
        if !valid_image_url?(image_url) || github_attachment_url?(image_url)
          LOGGER.warn("Removing invalid image URL: #{image_url}")
          true
        end
      end
    end

    def block_image_with_url?(block)
      block[:type] == 'image' && block.dig(:image, :external, :url)
    end

    def map_code_languages(notion_blocks)
      notion_blocks.each do |block|
        next unless block_code_with_language?(block)

        block[:code][:language] = 'shell' if block[:code][:language] == 'sh'
      end
    end

    def block_code_with_language?(block)
      block[:type] == 'code' && block.dig(:code, :language)
    end

    def add_image_urls(notion_blocks, markdown)
      image_urls = extract_image_urls(markdown)
      image_urls.each do |url|
        notion_blocks << build_image_url_paragraph(url)
      end
    end

    def build_image_url_paragraph(url)
      {
        type: 'paragraph',
        paragraph: {
          rich_text: [
            { text: { content: 'Image URL: ', link: nil } },
            { text: { content: url, link: { url: url } } }
          ]
        }
      }
    end

    def build_columns(static_blocks, notion_blocks)
      [
        build_column(static_blocks),
        build_column(notion_blocks)
      ]
    end

    def build_column(children)
      {
        type: 'column',
        column: {
          children: children
        }
      }
    end

    def build_column_list_block(columns)
      { type: 'column_list', column_list: { children: columns } }
    end

    def valid_image_url?(url)
      return false if url.nil? || url.strip.empty?

      uri = URI.parse(url)
      uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    rescue URI::InvalidURIError
      false
    end

    def github_attachment_url?(url)
      url.include?('github.com/user-attachments/')
    end

    def extract_image_urls(markdown)
      markdown.scan(/!\[.*?\]\((.*?)\)/).flatten.compact
    end

    def tag
      if process_response[:success].nil? || process_response[:success][:notion_wi].nil?
        return @shared_storage_writer.write_options[:tag]
      end

      UPDATE_REQUEST
    end
  end
end
