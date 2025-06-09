# frozen_string_literal: true

require 'httparty'
require 'googleauth'
require 'json'
require 'securerandom'

# This class serves as an implementation for managing spaces in Google Chat workspace
# using HTTP request instead of the client due to inconsistencies in the API documentation.
# This use App authentication but with an impersonated user
# It means that an application (the service account) is acting on behalf of a real domain user,
# as if it were that user, without any direct intervention from the user.
# This is done because without impersonating a user the service account has many limitations.
#
class GoogleChatSpaceManager
  SCOPE = [
    'https://www.googleapis.com/auth/chat.spaces',
    'https://www.googleapis.com/auth/chat.memberships',
    'https://www.googleapis.com/auth/chat.messages'
  ].freeze

  # Impersonated_user should be the bot account
  def initialize(service_account_credentials:, impersonated_user:)
    @service_account_credentials = StringIO.new(service_account_credentials)
    @impersonated_user = impersonated_user
    @access_token = authenticate
  end

  # The create space method allows you to create spaces ONLY of the space type,
  # NOT direct messages or group chats.
  # the members of the space will be the impersonated user and the users that you add using
  # the add member method.
  # With the impersonated user as the bot account you can start conversations.
  def create_space(display_name:, space_type: 'SPACE')
    body = { displayName: display_name, spaceType: space_type }.to_json

    response = HTTParty.post(
      'https://chat.googleapis.com/v1/spaces',
      headers: auth_headers,
      body: body
    )

    puts "Space created: #{response.code}"
    puts response.body
    response.parsed_response
  end

  # Add domain member to whom the bot will send messages
  def add_member(space_name:, user_email:)
    body = {
      member: { name: "users/#{user_email}", type: 'HUMAN' }
    }.to_json

    HTTParty.post(
      "https://chat.googleapis.com/v1/#{space_name}/members",
      headers: auth_headers,
      body: body
    )
  end

  def send_message(space_name:, text:)
    body = { text: text }.to_json

    response = HTTParty.post(
      "https://chat.googleapis.com/v1/#{space_name}/messages",
      headers: auth_headers,
      body: body
    )

    puts "Sent message: #{response.code}"
    puts response.body
    response
  end

  private

  def authenticate
    authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: @service_account_credentials,
      scope: SCOPE
    )
    authorizer.sub = @impersonated_user
    authorizer.fetch_access_token!
    authorizer.access_token
  end

  def auth_headers
    {
      'Authorization' => "Bearer #{@access_token}",
      'Content-Type' => 'application/json'
    }
  end
end
