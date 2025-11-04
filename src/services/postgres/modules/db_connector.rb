require 'sequel'

module Services
  module Postgres
    module DBConnector
      def establish_connection(config)
        Sequel.connect(
          adapter: 'postgres',
          host: config[:host],
          database: config[:dbname],
          user: config[:user],
          password: config[:password],
          port: config[:port]
        )
      end
    end
  end
end