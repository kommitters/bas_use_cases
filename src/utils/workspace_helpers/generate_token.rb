# frozen_string_literal: true

require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'webrick'
require 'json'
require 'launchy'
require 'fileutils'
require 'dotenv/load'

# This code is executed only once to create the token to use user authentication
# Before, make sure you have the corresponding configuration
# In Google Cloud project go to Apis & services -> credentials, create credentials -> OAuth client id
# In Application type select web application go to Authorized redirect URIs
# Add http://localhost:3000 and http://localhost:3000/oauth2callback
# Execute this file, dismiss the window that opens in the browser which URL gives a bad request
# copy the printed URL in your browser, this is the correct one
# The account you authorize is the one the bot will represent.
# All messages sent by your program will appear as sent by that account

APPLICATION_NAME = 'Google Chat Ruby OAuth Web'
USER_OAUTH_CREDENTIALS = ENV['USER_OAUTH_CREDENTIALS_JSON']
TOKEN_PATH = 'token.yaml'
SCOPE = ['https://www.googleapis.com/auth/chat.messages', 'https://www.googleapis.com/auth/chat.spaces'].freeze
REDIRECT_URI = 'http://localhost:3000'
USER_ID = 'default'

def load_client_id
  creds = JSON.parse(USER_OAUTH_CREDENTIALS)
  web = creds['web']
  Google::Auth::ClientId.new(web['client_id'], web['client_secret'])
end

def authorize_user
  prepare_token_storage
  authorizer = build_authorizer
  credentials = authorizer.get_credentials(USER_ID)

  if credentials.nil?
    code = launch_browser_and_get_code(authorizer)
    store_credentials(authorizer, code)
  else
    puts "Already exists token in #{TOKEN_PATH}"
  end

  puts "✅ Token saved in #{TOKEN_PATH}"
end

def prepare_token_storage
  FileUtils.mkdir_p(File.dirname(TOKEN_PATH))
end

def build_authorizer
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  client_id = load_client_id
  Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
end

def launch_browser_and_get_code(authorizer)
  url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
  puts "Open this URL in your browser: #{url}"
  Launchy.open(url)
  start_code_server
end

def start_code_server
  code = nil
  server = WEBrick::HTTPServer.new(Port: 3000, AccessLog: [], Logger: WEBrick::Log.new(File::NULL))

  server.mount_proc '/' do |req, res|
    code = req.query['code']
    res.body = '✅ Authentication completed. You can close this tab.'
    server.shutdown
  end

  trap('INT') { server.shutdown }
  server.start

  code
end

def store_credentials(authorizer, code)
  authorizer.get_and_store_credentials_from_code(
    user_id: USER_ID,
    code: code,
    base_url: REDIRECT_URI
  )
end
# Execute
authorize_user
