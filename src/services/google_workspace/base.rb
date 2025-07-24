# frozen_string_literal: true

require 'googleauth'

module Service
  module GoogleWorkspace
    ##
    # Base class for Google Workspace API services.
    #
    # This class centralizes authentication logic for connecting to Google APIs.
    # It uses service account credentials and impersonates a domain administrator
    # to perform actions on behalf of users.
    #
    class Base
      attr_reader :config, :credentials

      # Initializes the base service, handling authentication.
      def initialize(config, scope:)
        @config = config
        @credentials = authenticate(scope)
      end

      private

      # Authenticates using service account credentials and impersonates an admin user.
      def authenticate(scope)
        authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(config[:keyfile_path]),
          scope: scope
        )

        # Impersonate a domain admin to gain domain-wide access.
        authorizer.sub = config[:admin_email]
        authorizer.fetch_access_token!

        authorizer
      end

      ##
      # Abstract method for building the specific Google API service client.
      # This method MUST be implemented by any child class.
      #
      def build_service
        raise NotImplementedError, 'Subclasses must implement the #build_service method'
      end
    end
  end
end