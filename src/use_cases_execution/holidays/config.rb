# frozen_string_literal: true

##
# This file is used to store the configuration of the birthday use case.
# It contains the connection information to the database where the birthday data is stored.
# The connection information is stored in the CONNECTION constant.
#

require 'dotenv/load'

module Config
  CONNECTION = {
    host: ENV.fetch('ELASTIC_SEARCH_HOST'),
    port: ENV.fetch('ELASTIC_SEARCH_PORT'),
    user: ENV.fetch('ELASTIC_SEARCH_USER'),
    password: ENV.fetch('ELASTIC_SEARCH_PASSWORD'),
    ca_file: ENV.fetch('ELASTIC_SEARCH_CA_CERT_PATH')
  }.freeze
end
