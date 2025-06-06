# frozen_string_literal: true

require 'googleauth'
require 'google/apis/chat_v1'
require 'google/apis/admin_directory_v1'

# With impersonation we can send as a parameter to find_space_direct_message the user's email
# with which we want to get the space_id. This space_id corresponds to the direct message
# between the impersonated user and the user we send to find_space_direct_message.
# To do this we do not need to use Directory API therefore the impersonated user does not
# necessarily need to be a domain administrator.

# Without impersonation we get the space_id between the app and the user sent to find_space_direct_message
# but we can only send as a parameter to find_space_direct_message the user_id that is obtained with Directory API.
# However, Directory API requires impersonation with a domain administrator account to obtain the user_id

SERVICE_ACCOUNT_JSON = File.expand_path('../credentials-podnation.json', __dir__)
# Delegate to an admin of the domain allows you to get the user_id with Directory API
USER_TO_IMPERSONATE = 'info@podnation.co'
# This is the user with whom to start a DM
USER_EMAIL = 'service@podnation.co'

SCOPES = [
  'https://www.googleapis.com/auth/chat.spaces',
  'https://www.googleapis.com/auth/chat.messages',
  'https://www.googleapis.com/auth/admin.directory.user.readonly'
].freeze

# Creates an authorization object with or without impersonation
def authorize(impersonate: false)
  auth = Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(SERVICE_ACCOUNT_JSON),
    scope: SCOPES
  )
  auth.sub = USER_TO_IMPERSONATE if impersonate
  auth.fetch_access_token!
  auth
end

# Find the space between the impersonated user and another user (with email)
def find_dm_space_with_impersonation(user_email)
  chat = Google::Apis::ChatV1::HangoutsChatService.new
  chat.authorization = authorize(impersonate: true)

  response = chat.find_space_direct_message(name: "users/#{user_email}")
  puts "[Impersonation] Space between #{USER_TO_IMPERSONATE} and #{user_email}: #{response.name}"
end

# Get the user_id of Directory API using email
def fetch_user_id_from_email(email)
  directory = Google::Apis::AdminDirectoryV1::DirectoryService.new
  directory.authorization = authorize(impersonate: true)
  user = directory.get_user(email)
  user.id
end

# Find the space between the app and another user (with user_id)
def find_dm_space_without_impersonation(user_email)
  chat = Google::Apis::ChatV1::HangoutsChatService.new
  chat.authorization = authorize(impersonate: false)

  user_id = fetch_user_id_from_email(user_email)
  response = chat.find_space_direct_message(name: "users/#{user_id}")
  puts "[App Direct] Space between App and #{user_email} (#{user_id}): #{response.name}"
end

find_dm_space_with_impersonation(USER_EMAIL)
find_dm_space_without_impersonation(USER_EMAIL)
