require_relative './modules/db_connector'
require_relative './modules/crud'
require_relative './modules/relations'
require_relative './modules/audit'
require_relative './modules/utils'

module Services
  module Postgres
    class BaseAbstract
      include DBConnector
      include CRUD
      include Relations
      include Audit
      include Utils

      attr_reader :config, :db

      def initialize(config_or_db)
        if config_or_db.is_a?(Sequel::Database)
          @db = config_or_db
          @config = nil
        else
          @config = config_or_db
          @db = establish_connection(config)
        end
      end
    end
  end
end