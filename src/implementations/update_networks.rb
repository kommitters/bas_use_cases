# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/update_db_page'

module Implementation
  ##
  # The Implementation::UpdateNetworks class serves as a bot implementation to update "networks" on a
  # notion database using information of a GitHub issue.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "SearchUsersInApollo"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "UpdateNetworks"
  #   }
  #
  #   options = {
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::UpdateNetworks.new(options, shared_storage).execute
  #
  class UpdateNetworks < Bas::Bot::Base
    def process
      return { success: { updated: nil } } if unprocessable_response

      begin
        read_response.data['networks_list'].each { |network| update_email(network) }

        { success: { message: 'emails updated' } }
      rescue StandardError => e
        { error: { message: e.message } }
      end
    end

    private

    def update_email(network)
      return unless network['email']

      options = {
        page_id: network['id'],
        secret: process_options[:secret],
        body: { properties: { Email: network['email'], 'Email unavailable?' => false } }
      }

      Utils::Notion::UpdateDatabasePage.new(options).execute
    end
  end
end
