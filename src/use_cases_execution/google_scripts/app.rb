# frozen_string_literal: true

require 'sinatra/base'
require_relative '../pto/fetch_pto_from_google_for_workspace'

# WebServer is the main Sinatra application class.
# It mounts the available routes, including Routes::Pto, which handles PTO requests.
class WebServer < Sinatra::Base
  use Routes::Pto
end

if $PROGRAM_NAME == __FILE__
  WebServer.run!(
    server: :puma,
    bind: '0.0.0.0',
    environment: :production
  )
end
