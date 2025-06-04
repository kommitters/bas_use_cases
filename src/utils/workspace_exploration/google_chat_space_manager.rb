# frozen_string_literal: true

require 'httparty'
require 'googleauth'
require 'json'
require 'securerandom'

# This class serves as an implementation for managing spaces in Google Chat workspace
# using HTTP request instead of the client due to inconsistencies in the API documentation.
# The create space method allows you to create spaces ONLY of the space type,
# NOT direct messages or group chats.
# the members of the space will be the impersonated user and the users that you add using
# the add member method.
# With the impersonated user as the bot account you can start conversations.
#
class GoogleChatSpaceManager
  SCOPE = [
    'https://www.googleapis.com/auth/chat.spaces',
    'https://www.googleapis.com/auth/chat.memberships',
    'https://www.googleapis.com/auth/chat.messages'
  ].freeze

  def initialize(service_account_file:, impersonated_user:)
    @service_account_file = service_account_file
    @impersonated_user = impersonated_user
    @access_token = authenticate
  end

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
      json_key_io: File.open(@service_account_file),
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
