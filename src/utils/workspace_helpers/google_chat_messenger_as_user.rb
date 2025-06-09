# frozen_string_literal: true

require 'google/apis/chat_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'json'
require 'fileutils'
require 'time'

# Send direct message to user using user authentication and find space direct message
# which return the space_id between the user account associated with the token and
# the domain user email sent to find_space_direct_message.
# Send message with user authentication to any space indicating its id
#
class GoogleChatMessengerAsUser
  TOKEN_PATH = 'token.yaml'
  USER_ID = 'default'
  SCOPE = 'https://www.googleapis.com/auth/chat.messages'

  def initialize(user_oauth_credentials:)
    @user_oauth_credentials = user_oauth_credentials
    @client_id = load_client_id
    @chat_service = Google::Apis::ChatV1::HangoutsChatService.new
    @chat_service.authorization = authorized_client
  end

  def send_direct_message(target_email:, message:)
    msg = Google::Apis::ChatV1::Message.new(text: message)
    target_user = "users/#{target_email}"
    response = @chat_service.find_space_direct_message(name: target_user)
    space_id = response.name
    @chat_service.create_space_message(space_id, msg)
    puts "Message sent to #{target_email} (#{space_id})"
  end

  def send_message_to_space(space_name:, message:)
    msg = Google::Apis::ChatV1::Message.new(text: message)
    @chat_service.create_space_message(space_name, msg)
  end

  private

  def load_client_id
    creds = JSON.parse(@user_oauth_credentials)
    web = creds['web']
    Google::Auth::ClientId.new(web['client_id'], web['client_secret'])
  end

  def authorized_client
    FileUtils.mkdir_p(File.dirname(TOKEN_PATH))
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(@client_id, SCOPE, token_store)
    credentials = authorizer.get_credentials(USER_ID)

    raise 'Token not found. Run the authorization script first.' unless credentials

    credentials
  end
end
