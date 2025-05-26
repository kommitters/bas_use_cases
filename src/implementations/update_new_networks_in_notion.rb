# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/update_db_page'

module Implementation
  ##
  # The Implementation::UpdateNewNetworksInNotion class serves as a bot implementation to create "networks" on a
  # notion database using information from apollo.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "FetchNewNetworksFromApollo"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "UpdateNewNetworksInNotion"
  #   }
  #
  #   options = {
  #     secret: "notion_secret",
  #     database_id: "notion_database_id",
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::UpdateNewNetworksInNotion.new(options, shared_storage).execute
  #
  class UpdateNewNetworksInNotion < Bas::Bot::Base
    def process
      return { success: { updated: nil } } if unprocessable_response

      begin
        results = read_response.data['networks'].map { |network| create_network(network) }

        { success: { results: } }
      rescue StandardError => e
        { error: { message: e.message } }
      end
    end

    private

    def create_network(network)
      exist = verify_network_exists(network)
      return { linkedin_url: network['linkedin_url'] } if exist

      properties = format_network(network)

      result = Utils::Notion::Request.execute(params(properties))

      { code: result.code, message: result.parsed_response }
    end

    def params(properties)
      {
        endpoint: 'pages',
        secret: process_options[:secret],
        method: 'post',
        body: body(properties)
      }
    end

    def body(properties)
      {
        parent: { database_id: process_options[:database_id] },
        properties:
      }
    end

    def format_network(network)
      {
        "Status": { status: { name: 'Identified' } },
        "Name": { title: [{ text: { content: network['name'] } }] },
        "Connection Source": { select: { name: network['connection_source'] } },
        "LinkedIn": { url: network['linkedin_url'] }, "Role": { multi_select: [{ name: network['role'] }] },
        "Country": { multi_select: [{ name: network['country'] }] },
        "Email": { email: network['email'] },
        "Email unavailable?": { checkbox: false },
        "Industry (Networking)": { multi_select: [{ name: network['industry'] }] }
      }
    end

    def verify_network_exists(network)
      params = verify_exist_params(network)
      response = Utils::Notion::Request.execute(params)

      response.parsed_response['results'].any?
    end

    def verify_exist_params(network)
      {
        endpoint: "databases/#{process_options[:database_id]}/query",
        secret: process_options[:secret],
        method: 'post',
        body: exist_body(network)
      }
    end

    def exist_body(network)
      { filter: { property: 'LinkedIn', url: { equals: network['linkedin_url'] } } }
    end
  end
end
