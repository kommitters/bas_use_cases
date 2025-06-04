# frozen_string_literal: true

require_relative 'google_chat_space_manager'

# An example of how to use GoogleChatSpaceManager Class
# This use app authentication but with an impersonated user
# It means that an application (the service account) is acting on behalf of a real domain user,
# as if it were that user, without any direct intervention from the user.
# This is done because without impersonating a user the service account has many limitations.

# Impersonated_user should be the bot account
manager = GoogleChatSpaceManager.new(
  service_account_file: 'src\utils\credentials-podnation.json',
  impersonated_user: 'info@podnation.co'
)

space = manager.create_space(display_name: 'Noah Space 🤖')
space_name = space['name'] # e.g. "spaces/AAAAG..."

# Domain member to whom the bot will send messages
manager.add_member(space_name: space_name, user_email: 'service@podnation.co')

manager.send_message(space_name: space_name, text: 'Hello from the bot, activating @Noah Notificator')
