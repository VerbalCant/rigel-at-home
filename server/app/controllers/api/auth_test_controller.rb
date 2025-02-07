module Api
  class AuthTestController < BaseController
    skip_before_action :authenticate_request, only: [:login_options, :test_auth]

    def login_options
      Rails.logger.info("ALAINA: Fetching available login options")
      
      options = {
        providers: {
          google: {
            url: "/api/auth/auth/google_oauth2",
            name: "Google"
          },
          apple: {
            url: "/api/auth/auth/apple",
            name: "Apple"
          },
          microsoft: {
            url: "/api/auth/auth/microsoft_office365",
            name: "Microsoft"
          }
        }
      }

      Rails.logger.info("ALAINA: Available login options: #{options}")
      render json: options
    end

    def test_auth
      Rails.logger.info("ALAINA: Testing authentication status")
      if current_user
        render json: {
          authenticated: true,
          user: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            provider: current_user.provider
          }
        }
      else
        render json: { authenticated: false }
      end
    end
  end
end 