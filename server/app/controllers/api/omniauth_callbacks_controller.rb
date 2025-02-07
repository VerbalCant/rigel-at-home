module Api
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      Rails.logger.info("ALAINA: Received Google OAuth2 callback")
      handle_oauth("Google")
    end

    def apple
      Rails.logger.info("ALAINA: Received Apple OAuth callback")
      handle_oauth("Apple")
    end

    def microsoft_office365
      Rails.logger.info("ALAINA: Received Microsoft OAuth callback")
      handle_oauth("Microsoft")
    end

    private

    def handle_oauth(kind)
      Rails.logger.info("ALAINA: Processing OAuth callback for #{kind}")
      @user = User.from_omniauth(request.env['omniauth.auth'])
      
      if @user.persisted?
        token = JsonWebToken.encode(user_id: @user.id)
        Rails.logger.info("ALAINA: Successfully authenticated user: #{@user.email}")
        
        # Redirect to frontend with token and user data
        frontend_url = Rails.env.development? ? 'http://localhost:3001' : ENV['FRONTEND_URL']
        auth_data = {
          token: token,
          user: {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            provider: @user.provider
          }
        }
        
        redirect_url = "#{frontend_url}/auth/callback?#{auth_data.to_query}"
        Rails.logger.info("ALAINA: Redirecting to frontend: #{redirect_url}")
        redirect_to redirect_url, allow_other_host: true
      else
        Rails.logger.error("ALAINA: Failed to authenticate user: #{@user.errors.full_messages}")
        error_url = "#{frontend_url}/auth/callback?error=Authentication failed"
        redirect_to error_url, allow_other_host: true
      end
    end
  end
end 