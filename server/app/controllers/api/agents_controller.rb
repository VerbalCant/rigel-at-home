module Api
  class AgentsController < BaseController
    skip_before_action :authenticate_request, only: [:register]

    def register
      Rails.logger.info("ALAINA: Received agent registration request with params: #{params.inspect}")
      Rails.logger.info("ALAINA: Request headers: #{request.headers.to_h.select { |k, _| k.start_with?('HTTP_') }}")
      
      agent_attrs = agent_params
      agent_attrs[:status] = 'online'
      Rails.logger.info("ALAINA: Attempting to create agent with attributes: #{agent_attrs.inspect}")
      
      agent = Agent.new(agent_attrs)

      if agent.save
        token = JsonWebToken.encode(agent_id: agent.id)
        Rails.logger.info("ALAINA: Successfully registered agent: #{agent.name} with capabilities: #{agent.capabilities}")
        
        response.headers['Access-Control-Expose-Headers'] = 'Authorization'
        response.headers['Authorization'] = "Bearer #{token}"
        
        render json: {
          token: token,
          agent: {
            id: agent.id,
            name: agent.name,
            status: agent.status,
            capabilities: agent.capabilities
          }
        }, status: :created
      else
        Rails.logger.error("ALAINA: Agent registration failed: #{agent.errors.full_messages}")
        Rails.logger.error("ALAINA: Invalid agent attributes: #{agent.attributes.inspect}")
        render json: { errors: agent.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def heartbeat
      current_agent.update_last_seen!
      render json: { status: 'ok', timestamp: Time.current }
    end

    def update_status
      Rails.logger.info("ALAINA: Attempting to update agent status to: #{status_params[:status]}")
      if current_agent.update(status_params)
        Rails.logger.info("ALAINA: Agent #{current_agent.name} status updated to: #{current_agent.status}")
        render json: { status: 'ok', agent_status: current_agent.status }
      else
        Rails.logger.error("ALAINA: Failed to update agent status: #{current_agent.errors.full_messages}")
        render json: { errors: current_agent.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update_capabilities
      Rails.logger.info("ALAINA: Attempting to update agent capabilities to: #{capabilities_params.inspect}")
      if current_agent.update(capabilities: capabilities_params)
        Rails.logger.info("ALAINA: Agent #{current_agent.name} capabilities updated: #{current_agent.capabilities}")
        render json: { status: 'ok', capabilities: current_agent.capabilities }
      else
        Rails.logger.error("ALAINA: Failed to update agent capabilities: #{current_agent.errors.full_messages}")
        render json: { errors: current_agent.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def agent_params
      params.require(:agent).permit(:name, capabilities: {})
    end

    def status_params
      params.permit(:status)
    end

    def capabilities_params
      params.require(:capabilities).permit!
    end
  end
end