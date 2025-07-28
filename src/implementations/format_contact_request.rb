# frozen_string_literal: true

require 'bas/bot/base'
module Implementation
  ##
  # The Bot::FormatContactRequest class serves as a bot implementation to read contact request from a
  # PostgresDB database, format them with a specific template, and write them on a PostgresDB
  # table with a specific format.
  #
  # <br>
  # Example
  # read_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'website_form_contact',
  #   tag: 'WebsiteContactFormWebhook'
  # }
  #
  # write_options = {
  #   connection: Config::CONNECTION,
  #   db_table: 'website_form_contact',
  #   tag: 'FormatWebsiteContactForm'
  # }
  #
  # options = {
  #   template: "<name> (<email>)\n   <thematics>"
  # }
  # shared_storage_reader = Bas::SharedStorage::Postgres.new(read_options:)
  # shared_storage_writer = Bas::SharedStorage::Postgres.new(write_options:)
  # Bot::FormatContactRequest.new(options, shared_storage_reader, shared_storage_writer).execute
  #
  class FormatContactRequest < Bas::Bot::Base
    # Process function to format the notification using a template
    #
    def process
      return { success: { notification: '' } } if unprocessable_response

      notification = (
        if read_response.data['feature'] == 'contact_form'
          build_contact_template(read_response.data)
        else
          build_verification_template(read_response.data)
        end
      )

      { success: { notification: } }
    end

    private

    def build_contact_template(data)
      process_options[:contact_template]
        .gsub('<name>', data['name'])
        .gsub('<email>', data['email'])
        .gsub('<thematics>', data['thematic'].map { |t| "• #{t}" }.join("\n   "))
    end

    def build_verification_template(data)
      process_options[:verification_template]
        .gsub('<org_name>', data['org_name'])
        .gsub('<email>', data['email'])
        .gsub('<certificate_url>', data['certificate_url'])
    end
  end
end
