# frozen_string_literal: true

require 'sinatra/base'
require_relative '../birthday/fetch_birthdays_from_google'
require_relative '../birthday_next_week/fetch_next_week_birthday_from_google_for_workspace'

# The WebServer class defines the main Sinatra application responsible for
# handling incoming webhooks from Google services.

# This server acts as a central entry point and delegates the handling of
# specific routes to the `Routes` class, which contains the definitions
# for all available endpoints.
# WebServer is the main Sinatra application class.
class WebServer < Sinatra::Base
  use Routes::Birthdays
  use Routes::NextWeekBirthdays

  get('/') { 'OK' }
end

if $PROGRAM_NAME == __FILE__
  WebServer.run!(
    server: :puma,
    bind: '0.0.0.0',
    environment: :production
  )
end
