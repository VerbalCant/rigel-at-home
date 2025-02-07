module Api
  class AuthTestController < BaseController
    skip_before_action :authenticate_request, only: [:login_options, :test_auth]

    def login_options
      Rails.logger.info("ALAINA: Fetching available login options")
      
      options = {
        providers: {
          google: {
            url: user_google_oauth2_omniauth_authorize_path,
            name: "Google"
          },
          apple: {
            url: user_apple_omniauth_authorize_path,
            name: "Apple"
          },
          microsoft: {
            url: user_microsoft_office365_omniauth_authorize_path,
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