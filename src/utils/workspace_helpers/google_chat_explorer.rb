# frozen_string_literal: true

require 'google/apis/chat_v1'
require 'google/apis/admin_directory_v1'
require 'googleauth'
require 'dotenv/load'
# This class serves as an implementation for managing spaces in Google Chat workspace
# using Google Chat API with service account credentials and impersonation when is needed
#
class GoogleChatExplorer
  CHAT_SCOPES = [
    'https://www.googleapis.com/auth/chat.spaces',
    'https://www.googleapis.com/auth/chat.memberships',
    'https://www.googleapis.com/auth/chat.messages'
  ].freeze

  DIRECTORY_SCOPES = [
    'https://www.googleapis.com/auth/admin.directory.user.readonly'
  ].freeze

  def initialize(service_account_credentials:, impersonated_user: nil, impersonated_admin_user: nil)
    @service_account_credentials = service_account_credentials
    @impersonated_user = impersonated_user
    @impersonated_admin_user = impersonated_admin_user
  end

  # ----- Chat authorization (impersonated or not) -----
  def authorize_chat(impersonate: false)
    auth = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(@service_account_credentials),
      scope: CHAT_SCOPES
    )
    auth.sub = @impersonated_user if impersonate & @impersonated_user
    auth.fetch_access_token!
    auth
  end

  # ----- Directory authorization (requires admin impersonation) -----
  def authorize_directory
    raise ArgumentError, 'Admin impersonation required for Directory API' unless @impersonated_admin_user

    auth = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(@service_account_credentials),
      scope: DIRECTORY_SCOPES
    )
    auth.sub = @impersonated_admin_user
    auth.fetch_access_token!
    auth
  end

  def chat_service(impersonate: false)
    service = Google::Apis::ChatV1::HangoutsChatService.new
    service.authorization = authorize_chat(impersonate: impersonate)
    service
  end

  # ----- List spaces (app context only) -----
  # We can also use impersonation to get all the spaces of the impersonated user.
  def list_spaces
    response = chat_service.list_spaces(page_size: 100)
    response.spaces.map do |space|
      {
        name: space.name,
        display_name: space.display_name || '(no display name)',
        space_type: space.space_type
      }
    end
  end

  # ----- List members in a given space -----
  def list_space_members(space_name)
    members = chat_service.list_space_members("spaces/#{space_name}")&.memberships || []
    format_human_members(members)
  rescue StandardError => e
    puts "Error fetching members for #{space_name}: #{e.message}"
    []
  end

  # ----- Find DM space between impersonated user and another user -----
  def find_dm_space_with_impersonation(target_email)
    response = chat_service(impersonate: true).find_space_direct_message(name: "users/#{target_email}")
    response.name
  end

  # ----- Find DM space between the app and a user by user_id -----
  def find_dm_space_without_impersonation(target_email)
    user_id = fetch_user_id(target_email)

    response = chat_service.find_space_direct_message(name: "users/#{user_id}")
    response.name
  end

  # -----  Fetch user_id from Directory API -----
  def fetch_user_id(email)
    directory = Google::Apis::AdminDirectoryV1::DirectoryService.new
    directory.authorization = authorize_directory

    directory.get_user(email).id
  end

  def format_human_members(members)
    members.reject { |m| m.member&.type == 'BOT' }.map do |member|
      {
        user_id: member.member.name,
        member_name: member.member.display_name
      }
    end
  end
end
