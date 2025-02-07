module Api
  class BaseController < ActionController::API
    before_action :authenticate_request

    private

    def authenticate_request
      return true if skip_authentication?

      header = request.headers['Authorization']
      if header&.start_with?('Bearer')
        # Try both user and agent authentication
        authenticate_user_token || authenticate_agent_token
      else
        Rails.logger.error("ALAINA: Missing or invalid Authorization header")
        render json: { error: 'Missing or invalid Authorization header' }, status: :unauthorized
        false
      end
    end

    def authenticate_user_token
      header = request.headers['Authorization']
      token = header.split(' ').last
      begin
        @decoded = JsonWebToken.decode(token)
        if @decoded.nil? || !@decoded[:user_id]
          Rails.logger.info("ALAINA: Not a user token")
          return false
        end
        @current_user = User.find(@decoded[:user_id])
        true
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.info("ALAINA: User not found: #{e.message}")
        false
      rescue JWT::DecodeError => e
        Rails.logger.info("ALAINA: Invalid user token: #{e.message}")
        false
      end
    end

    def authenticate_agent_token
      header = request.headers['Authorization']
      token = header.split(' ').last
      begin
        @decoded = JsonWebToken.decode(token)
        if @decoded.nil? || !@decoded[:agent_id]
          Rails.logger.error("ALAINA: Not an agent token")
          render json: { error: 'Invalid token' }, status: :unauthorized
          return false
        end
        @current_agent = Agent.find(@decoded[:agent_id])
        true
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error("ALAINA: Agent not found: #{e.message}")
        render json: { error: 'Agent not found' }, status: :unauthorized
        false
      rescue JWT::DecodeError => e
        Rails.logger.error("ALAINA: Invalid token: #{e.message}")
        render json: { error: 'Invalid token' }, status: :unauthorized
        false
      end
    end

    def current_user
      @current_user
    end

    def current_agent
      @current_agent
    end

    def skip_authentication?
      controller_name == 'agents' && action_name == 'register' ||
      (controller_name == 'task_definitions' && %w[index show].include?(action_name)) ||
      (controller_name == 'auth_test' && %w[login_options test_auth].include?(action_name)) ||
      (controller_name == 'auth' && action_name == 'callback')
    end
  end
end