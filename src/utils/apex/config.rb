# frozen_string_literal: true

+##
+# Configuration for APEX API integration.
+# Exposes constants for the OAuth base URL, API base URL, and client credentials,
+# all sourced from environment variables (see .env.example).
+##

require 'dotenv/load'

module Config
  APEX_OAUTH_BASE    = ENV.fetch('APEX_OAUTH_BASE')
  APEX_API_BASE      = ENV.fetch('APEX_API_BASE')
  APEX_CLIENT_ID     = ENV.fetch('APEX_CLIENT_ID')
  APEX_CLIENT_SECRET = ENV.fetch('APEX_CLIENT_SECRET')
end
