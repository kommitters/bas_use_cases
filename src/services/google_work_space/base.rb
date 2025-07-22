# frozen_string_literal: true

require 'googleauth'

module Service
  module GoogleWorkSpace
    # Base class for Google Workspace API services.
    #
    # This class centralizes the authentication logic for connecting to Google
    # APIs. It uses service account credentials passed via a configuration hash
    # and always impersonates a domain administrator to perform actions.
    class Base
      attr_reader :config, :credentials

      # Initializes the service.
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

        auth_as_admin = authorizer.dup
        auth_as_admin.sub = config[:admin_email]
        auth_as_admin.fetch_access_token!

        auth_as_admin
      end

      # This method MUST be implemented by any child class.
      def build_service
        raise NotImplementedError, 'Subclasses must implement the #build_service method'
      end
    end
  end
end
