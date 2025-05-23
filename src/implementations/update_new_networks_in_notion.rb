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
        read_response.data['networks'].each { |network| create_network(network) }

        { success: { message: 'emails updated' } }
      rescue StandardError => e
        { error: { message: e.message } }
      end
    end

    private

    def create_network(network)
      properties = format_network(network)

      Utils::Notion::Request.execute(params(properties))
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
        "Status": network['status'], "Name": network['name'],
        "Connection Source": network['connection_source'],
        "Linkedin": network['linkedin'], "Role": network['role'],
        "Country": network['country'],
        "Qualification": network['qualification'],
        "Email": network['email'], "Email Unavailable": true
      }
    end
  end
end
