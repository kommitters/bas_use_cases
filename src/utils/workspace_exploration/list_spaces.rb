# frozen_string_literal: true

require 'google/apis/chat_v1'
require 'googleauth'

SCOPES = [
  'https://www.googleapis.com/auth/chat.bot',
  'https://www.googleapis.com/auth/chat.app.spaces'
].freeze

SERVICE_ACCOUNT_FILE = File.expand_path('../credentials-podnation.json', __dir__)

def authorize_service_account
  Google::Auth::ServiceAccountCredentials.make_creds(
    json_key_io: File.open(SERVICE_ACCOUNT_FILE),
    scope: SCOPES
  ).tap(&:fetch_access_token!)
end

# List all the active spaces that the app has
def list_spaces_info(chat_service)
  spaces_info = []

  response = chat_service.list_spaces(page_size: 100)

  response.spaces.each do |space|
    info = { name: space.name,
             display_name: space.display_name || '(no display name)',
             space_type: space.space_type }
    spaces_info << info
  end

  spaces_info
end

# List all human members in a space
def list_space_members(chat_service, spaces_info)
  spaces_info.each do |space|
    print_space_member_info(chat_service, space)
  end
end

def print_space_member_info(chat_service, space)
  members = chat_service.list_space_members(space_name)&.memberships || []
  human_member = members.find { |m| m.member&.type != 'BOT' }

  if human_member
    print_human_member_info(space, human_member)
  else
    puts "Space: #{space[:name]} - No human members found."
  end
rescue StandardError => e
  puts "Error fetching members for space #{space[:name]}: #{e.message}"
end

# With the User ID we can use Directory API to get the user email
def print_human_member_info(space, member)
  puts "Space: #{space[:name]} (#{space[:display_name]}, #{space[:space_type]})"
  puts "    User ID: #{member.member.name}"
  puts "    User name: #{member.member.display_name}"
end

# Main execution
chat_service = Google::Apis::ChatV1::HangoutsChatService.new
chat_service.authorization = authorize_service_account

spaces_info = list_spaces_info(chat_service)
list_space_members(chat_service, spaces_info)
