# frozen_string_literal: true

##
# This file is used to store the configuration of the pto use case.
# It contains the connection information to the database where the pto data is stored.
# The connection information is stored in the CONNECTION constant.
#

require 'dotenv/load'

module Config
  APEX_OAUTH_BASE    = ENV.fetch("APEX_OAUTH_BASE")
  APEX_API_BASE      = ENV.fetch("APEX_API_BASE")
  APEX_CLIENT_ID     = ENV.fetch("APEX_CLIENT_ID")
  APEX_CLIENT_SECRET = ENV.fetch("APEX_CLIENT_SECRET")
end
