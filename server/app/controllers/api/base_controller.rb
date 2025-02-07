module Api
  class BaseController < ApplicationController
    before_action :authenticate_request

    private

    def authenticate_request
      return true if skip_authentication?

      header = request.headers['Authorization']
      if header.blank?
        puts "ALAINA: Missing Authorization header"
        render json: { error: 'Missing Authorization header' }, status: :unauthorized
        return false
      end

      token = header.split(' ').last
      begin
        @decoded = JsonWebToken.decode(token)
        if @decoded.nil?
          puts "ALAINA: Invalid or expired token"
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
          return false
        end
        @current_agent = Agent.find(@decoded[:agent_id])
        true
      rescue ActiveRecord::RecordNotFound => e
        puts "ALAINA: Agent not found: #{e.message}"
        render json: { error: 'Agent not found' }, status: :unauthorized
        false
      rescue JWT::DecodeError => e
        puts "ALAINA: Invalid token: #{e.message}"
        render json: { error: 'Invalid token' }, status: :unauthorized
        false
      end
    end

    def current_agent
      @current_agent
    end

    def skip_authentication?
      controller_name == 'agents' && action_name == 'register' ||
      (controller_name == 'task_definitions' && %w[index show].include?(action_name))
    end
  end
end