# frozen_string_literal: true

require 'google/apis/chat_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'json'
require 'fileutils'
require 'time'

# Send direct message to user using user authentication and find space direct message
# which return the space_id between the user account associated with the token and
# the domain user email sent to find_space_direct_message

# Config
CREDENTIALS_PATH = 'src/utils/user-web-credentials.json'
TOKEN_PATH = 'token.yaml'
SCOPE = 'https://www.googleapis.com/auth/chat.messages'
USER_ID = 'default'

def load_client_id
  creds = JSON.parse(File.read(CREDENTIALS_PATH))
  web = creds['web']
  Google::Auth::ClientId.new(web['client_id'], web['client_secret'])
end

def authorized_client
  FileUtils.mkdir_p(File.dirname(TOKEN_PATH))
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(load_client_id, SCOPE, token_store)
  credentials = authorizer.get_credentials(USER_ID)

  raise 'The token was not found. Run the authorization script first.' unless credentials

  credentials
end

def send_direct_message(to_email:, message:)
  service = Google::Apis::ChatV1::HangoutsChatService.new
  service.authorization = authorized_client

  msg = Google::Apis::ChatV1::Message.new(text: message)

  target_user = "users/#{to_email}"
  response = service.find_space_direct_message(name: target_user)
  space_id = response.name
  service.create_space_message(space_id, msg)
  puts "Message sended to #{to_email} #{space_id}"
end

send_direct_message(
  to_email: 'service@podnation.co',
  message: '👋 Hi, this is a DM.'
)
