# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/notion/request'

module Implementation
  ##
  # The Implementation::UpdateBrevoContacts class serves as a bot implementation to update "networks" on a
  # notion database using information from apollo
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "FetchNetworksFromNotion"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "apollo_sync",
  #     tag: "UpdateBrevoContacts"
  #   }
  #
  #   options = {
  #     secret: "notion_secret"
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::UpdateBrevoContacts.new(options, shared_storage).execute
  #
  class UpdateBrevoContacts < Bas::Bot::Base
    BREVO_API_URL = 'https://api.brevo.com/v3'

    def process
      return { success: { updates: [] } } if unprocessable_response

      networks_list = read_response.data['networks_list'].map { |contact| create_update_contact(contact) }

      { success: { networks_list: } }
    end

    private

    def create_update_contact(contact)
      body = {
        'email' => contact['email'],
        'updateEnabled' => true,
        'listIds' => [process_options[:brevo_list_id].to_i],
        'attributes' => contact_body(contact)
      }

      response = brevo_client(method: :post, endpoint: 'contacts', body:)
      response if response.code == 201
    end

    def contact_body(contact)
      {
        'ROLE' => contact['role'],
        'COUNTRY' => contact['country'],
        'LINKEDIN' => contact['linkedin_url'],
        'QUALIFICATION' => contact['qualification'],
        'INDUSTRY' => contact['industry_networking']
      }
    end

    def brevo_client(config)
      url = "#{BREVO_API_URL}/#{config[:endpoint]}"

      HTTParty.send(config[:method], url, headers:, body: config[:body].to_json)
    end

    def headers
      {
        'api-key' => process_options[:brevo_token],
        'Content-Type' => 'application/json'
      }
    end
  end
end
