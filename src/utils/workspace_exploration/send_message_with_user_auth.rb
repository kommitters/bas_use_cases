# frozen_string_literal: true

require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/chat_v1'

# Send message with user authentication to any space indicating its id

CREDENTIALS_PATH = 'src/utils/user-web-credentials.json'
TOKEN_PATH = 'token.yaml'

SCOPE = ['https://www.googleapis.com/auth/chat.messages', 'https://www.googleapis.com/auth/chat.spaces.create'].freeze

def authorized_client
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'

  credentials = authorizer.get_credentials(user_id)
  raise 'The token was not found. Run the authorization script first.' if credentials.nil?

  credentials
end

def send_message_to_space(space_name, message_text)
  chat_service = Google::Apis::ChatV1::HangoutsChatService.new
  chat_service.authorization = authorized_client

  message = Google::Apis::ChatV1::Message.new(text: message_text)
  chat_service.create_space_message(space_name, message)
end

space = 'spaces/hIfcX8AAAAE'
text = 'Hello from my bot with user authentication👋'

send_message_to_space(space, text)
