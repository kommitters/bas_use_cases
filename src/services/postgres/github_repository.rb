# frozen_string_literal: true

require_relative 'base'

module Services
  module Postgres
    ##
    # Github Repository Service for PostgreSQL
    #
    # Provides CRUD operations for the 'github_repositories' table using the Base service.
    class GithubRepository < Services::Postgres::Base
    end
  end
end
