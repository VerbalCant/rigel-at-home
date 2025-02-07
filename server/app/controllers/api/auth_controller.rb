module Api
  class AuthController < BaseController
    skip_before_action :authenticate_request, only: [:callback]

    def callback
      Rails.logger.info("ALAINA: Received OAuth callback for provider: #{auth_hash.provider}")
      
      @user = User.from_omniauth(auth_hash)
      
      if @user.persisted?
        token = JsonWebToken.encode(user_id: @user.id)
        Rails.logger.info("ALAINA: Successfully authenticated user: #{@user.email}")
        
        render json: {
          token: token,
          user: {
            id: @user.id,
            email: @user.email,
            name: @user.name,
            provider: @user.provider
          }
        }, status: :ok
      else
        Rails.logger.error("ALAINA: Failed to authenticate user: #{@user.errors.full_messages}")
        render json: { error: 'Authentication failed' }, status: :unprocessable_entity
      end
    end

    private

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end 